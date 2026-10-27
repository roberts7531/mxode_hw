module sd_reader #(
    parameter [2:0] CLK_DIV = 3'd1,
    parameter       SIMULATE = 0
)(
    input  wire        rstn,
    input  wire        clk,

    output wire        sdclk,
    inout              sdcmd,
    input  wire [3:0]  sddat,

    input  wire        rstart,
    input  wire [31:0] startLba,
    input  wire [31:0] count,

    output wire        rbusy,
    output wire        rdone,

    // Sticky hard-error flag for the current multi-block read (timeout on
    // CMD18, on a data start token, or on CMD12).  Cleared when the next
    // read is accepted or on reset, so it can be polled as "the last read
    // did not complete".
    output reg         rerror,
    output reg         init_done,      // card identification completed

    output reg         outen,
    output reg  [15:0] outaddr,
    output reg  [7:0]  outbyte
);

localparam [1:0] UNKNOWN = 2'd0,
                 SDv1    = 2'd1,
                 SDv2    = 2'd2,
                 SDHCv2  = 2'd3;

// SD clock divider values (core clock is 90 MHz).
// sdcmd_ctrl period = 2*(clkdiv+1)+2 core clocks.
//   clkdiv = 0      -> 4 core clocks -> 22.5 MHz (default-speed limit is 25 MHz)
//   clkdiv = 96     -> 196 core clocks -> ~459 kHz (identification)
//   clkdiv = 0xFFFF -> 2 core clocks -> 45 MHz (SD high-speed mode)
localparam [15:0] FASTCLKDIV = SIMULATE ? 16'd2 : 16'd0;
localparam [15:0] SLOWCLKDIV = SIMULATE ? 16'd4 : 16'd96;
localparam [15:0] HS_DIV     = 16'hFFFF; // 45 MHz, used only after the card accepts high-speed mode

localparam [31:0] TOKEN_TIMEOUT = 32'd1000000;

// ------------------------------------------------------------
// Command controller interface
// ------------------------------------------------------------

reg        start = 1'b0;
reg [15:0] precnt = 0;
reg [5:0]  cmd = 0;
reg [31:0] arg = 0;
reg [15:0] clkdiv = SLOWCLKDIV;

wire        busy;
wire        done;
wire        timeout;
wire        syntaxe;
wire [31:0] resparg;

reg [15:0] rca = 0;
reg        sdv1_maybe = 0;
reg [2:0]  cmd8_cnt = 0;
reg [1:0]  card_type = UNKNOWN;

reg [31:0] transfer_lba = 0;
reg [31:0] transfer_count = 0;
reg [31:0] sectors_done = 0;

// ------------------------------------------------------------
// Main FSM
// ------------------------------------------------------------

localparam [4:0]
    ST_CMD0       = 5'd0,
    ST_CMD8       = 5'd1,
    ST_CMD55_41   = 5'd2,
    ST_ACMD41     = 5'd3,
    ST_CMD2       = 5'd4,
    ST_CMD3       = 5'd5,
    ST_CMD7       = 5'd6,
    ST_CMD55_6    = 5'd7,
    ST_ACMD6      = 5'd8,
    ST_CMD16      = 5'd9,
    ST_READY      = 5'd10,

    ST_CMD18_START = 5'd11,
    ST_CMD18_WAIT  = 5'd12,

    ST_DATA_WAIT   = 5'd13,
    ST_DATA_READ   = 5'd14,
    ST_DATA_TAIL   = 5'd15,

    ST_CMD12_START = 5'd16,
    ST_CMD12_WAIT  = 5'd17,

    ST_READ_DONE   = 5'd18,

    ST_HS_CMD       = 5'd19,
    ST_HS_CMD_WAIT  = 5'd20,
    ST_HS_DATA_WAIT = 5'd21,
    ST_HS_DATA      = 5'd22,
    ST_HS_TAIL      = 5'd23,

    // Silent retry after a missing data token: stop the stream, let the bus
    // settle, then re-read the whole chunk from its first sector.
    ST_RETRY_START = 5'd24,
    ST_RETRY_WAIT  = 5'd25,
    ST_RETRY_IDLE  = 5'd26;

reg [4:0] state = ST_CMD0;

assign rbusy = (state != ST_READY &&
                state != ST_READ_DONE);

assign rdone = (state == ST_READ_DONE);

// ------------------------------------------------------------
// SD data receiver
// ------------------------------------------------------------

reg        sdclkl = 0;

reg [31:0] token_wait = 0;
reg [9:0]  nibble_count = 0;
reg [7:0]  tail_count = 0;

// CMD6 (SWITCH_FUNC) status-block capture
reg [9:0]  hs_nibble = 0;
reg [8:0]  hs_byte_idx = 0;
reg [3:0]  hs_hi = 0;
reg [7:0]  hs_byte13 = 0;
reg [7:0]  hs_byte16 = 0;
reg [7:0]  hs_tail_count = 0;
reg [31:0] hs_token_wait = 0;

reg [31:0] byte_addr = 0;

// Silent retry-on-token-timeout bookkeeping.
reg [1:0]  retry_count = 0;
reg [7:0]  retry_idle = 0;
reg [15:0] retry_timeout = 0;

// All data/token sampling happens on the SD clock rising edge, matching the
// command response path in sdcmd_ctrl.
wire sd_rising = sdclk_sample;

// ------------------------------------------------------------
// Command controller instance
// ------------------------------------------------------------

sdcmd_ctrl sdcmd_ctrl_i (
    .rstn     (rstn),
    .clk      (clk),
    .sdclk    (sdclk),
    .sdclk_sample(sdclk_sample),
    .sdcmd    (sdcmd),
    .clkdiv   (clkdiv),
    .start    (start),
    .precnt   (precnt),
    .cmd      (cmd),
    .arg      (arg),
    .busy     (busy),
    .done     (done),
    .timeout  (timeout),
    .syntaxe  (syntaxe),
    .resparg  (resparg)
);

// ------------------------------------------------------------
// Command helper
// ------------------------------------------------------------

task automatic set_cmd(
    input        _start,
    input [15:0] _precnt,
    input [5:0]  _cmd,
    input [31:0] _arg
);
begin
    start  <= _start;
    precnt <= _precnt;
    cmd    <= _cmd;
    arg    <= _arg;
end
endtask

// ------------------------------------------------------------
// Main state machine and data receiver
// ------------------------------------------------------------

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        set_cmd(0, 0, 0, 0);

        clkdiv <= SLOWCLKDIV;

        card_type  <= UNKNOWN;
        rca        <= 0;
        sdv1_maybe <= 0;
        cmd8_cnt   <= 0;

        transfer_lba   <= 0;
        transfer_count <= 0;
        sectors_done   <= 0;

        state <= ST_CMD0;

        outen   <= 0;
        outaddr <= 0;
        outbyte <= 0;

        sdclkl         <= 0;
        token_wait     <= 0;
        nibble_count   <= 0;
        tail_count     <= 0;
        byte_addr      <= 0;

        retry_count    <= 0;
        retry_idle     <= 0;
        retry_timeout  <= 0;
        init_done      <= 0;

        hs_nibble      <= 0;
        hs_byte_idx    <= 0;
        hs_hi          <= 0;
        hs_byte13      <= 0;
        hs_byte16      <= 0;
        hs_tail_count  <= 0;
        hs_token_wait  <= 0;

        rerror         <= 1'b0;

    end else begin

        // Defaults: command start and output enable are pulses.
        set_cmd(0, 0, 0, 0);

        outen  <= 0;
        sdclkl <= sdclk;

        case (state)

        // ====================================================
        // Initialization
        // ====================================================

        ST_CMD0: begin
            if (!busy) begin
                set_cmd(1, SIMULATE ? 512 : 64000, 0, 0);
            end else if (done) begin
                state <= ST_CMD8;
            end
        end

        ST_CMD8: begin
            if (!busy) begin
                set_cmd(1, 512, 8, 32'h000001AA);
            end else if (done) begin
                if (!timeout && !syntaxe &&
                    resparg[7:0] == 8'hAA) begin
                    state <= ST_CMD55_41;
                end else if (timeout) begin
                    cmd8_cnt <= cmd8_cnt + 1'b1;

                    if (&cmd8_cnt) begin
                        sdv1_maybe <= 1'b1;
                        state <= ST_CMD55_41;
                    end
                end
            end
        end

        ST_CMD55_41: begin
            if (!busy) begin
                set_cmd(1, 512, 55, 0);
            end else if (done) begin
                if (!timeout && !syntaxe)
                    state <= ST_ACMD41;
            end
        end

        ST_ACMD41: begin
            if (!busy) begin
                set_cmd(1, 256, 41, 32'h40100000);
            end else if (done) begin
                if (!timeout && !syntaxe && resparg[31]) begin
                    card_type <= sdv1_maybe ? SDv1 :
                                 resparg[30] ? SDHCv2 : SDv2;

                    state <= ST_CMD2;
                end else begin
                    state <= ST_CMD55_41;
                end
            end
        end

        ST_CMD2: begin
            if (!busy) begin
                set_cmd(1, 256, 2, 0);
            end else if (done) begin
                if (!timeout && !syntaxe)
                    state <= ST_CMD3;
            end
        end

        ST_CMD3: begin
            if (!busy) begin
                set_cmd(1, 256, 3, 0);
            end else if (done) begin
                if (!timeout && !syntaxe) begin
                    rca <= resparg[31:16];
                    state <= ST_CMD7;
                end
            end
        end

        ST_CMD7: begin
            if (!busy) begin
                set_cmd(1, 256, 7, {rca, 16'h0000});
            end else if (done) begin
                if (!timeout && !syntaxe) begin
                    clkdiv <= FASTCLKDIV;
                    state <= ST_CMD55_6;
                end
            end
        end

        ST_CMD55_6: begin
            if (!busy) begin
                set_cmd(1, 256, 55, {rca, 16'h0000});
            end else if (done) begin
                if (!timeout && !syntaxe)
                    state <= ST_ACMD6;
            end
        end

        ST_ACMD6: begin
            if (!busy) begin
                set_cmd(1, 256, 6, 32'h00000002);
            end else if (done) begin
                if (!timeout && !syntaxe)
                    state <= ST_CMD16;
            end
        end

        ST_CMD16: begin
            if (!busy) begin
                set_cmd(1, SIMULATE ? 512 : 64000,
                        16, 32'h00000200);
            end else if (done) begin
                if (!timeout && !syntaxe) begin
                    // Identification is complete: the card is selected and its
                    // block length is set, so a healthy idle link can be reused
                    // by a driver reload instead of being reset.
                    init_done <= 1'b1;

                    // SDv1 cards do not implement CMD6.
                    if (card_type == SDv1)
                        state <= ST_READY;
                    else
                        state <= ST_HS_CMD;
                end
            end
        end

        // ====================================================
        // CMD6: select high-speed mode (50 MHz timing mode)
        // ====================================================

        ST_HS_CMD: begin
            if (!busy) begin
                // mode=1, all groups 0xF (no change), group 1 = 1 (high speed)
                set_cmd(1, 16, 6, 32'h80FFFFF1);
                state <= ST_HS_CMD_WAIT;
            end
        end

        ST_HS_CMD_WAIT: begin
            if (done) begin
                if (!timeout && !syntaxe) begin
                    hs_nibble     <= 0;
                    hs_byte_idx   <= 0;
                    hs_hi         <= 0;
                    hs_byte13     <= 0;
                    hs_byte16     <= 0;
                    hs_tail_count <= 0;
                    hs_token_wait <= 0;
                    state <= ST_HS_DATA_WAIT;
                end else begin
                    // No CMD6 support: stay at the default-speed clock.
                    state <= ST_READY;
                end
            end
        end

        ST_HS_DATA_WAIT: begin
            if (sd_rising) begin
                if (sddat == 4'b0000) begin
                    hs_token_wait <= 0;
                    hs_nibble     <= 0;
                    hs_byte_idx   <= 0;
                    hs_hi         <= 0;
                    state <= ST_HS_DATA;
                end else if (hs_token_wait >= TOKEN_TIMEOUT) begin
                    state <= ST_READY;
                end else begin
                    hs_token_wait <= hs_token_wait + 1'b1;
                end
            end
        end

        ST_HS_DATA: begin
            if (sd_rising) begin
                if (!hs_nibble[0]) begin
                    hs_hi <= sddat;
                end else begin
                    if (hs_byte_idx == 13)
                        hs_byte13 <= {hs_hi, sddat};
                    if (hs_byte_idx == 16)
                        hs_byte16 <= {hs_hi, sddat};

                    hs_byte_idx <= hs_byte_idx + 1'b1;
                end

                if (hs_nibble == 10'd127) begin
                    hs_nibble <= 0;
                    state <= ST_HS_TAIL;
                end else begin
                    hs_nibble <= hs_nibble + 1'b1;
                end
            end
        end

        ST_HS_TAIL: begin
            if (sd_rising) begin
                if (hs_tail_count >= 8'd17) begin
                    // byte 13 bit 1: function 1 (high speed) is supported in group 1
                    // byte 16 bits 3:0: currently selected group 1 function (1 = high speed)
                    if (hs_byte13[1] && (hs_byte16[3:0] == 4'h1))
                        clkdiv <= HS_DIV;

                    state <= ST_READY;
                end else begin
                    hs_tail_count <= hs_tail_count + 1'b1;
                end
            end
        end

        // ====================================================
        // Idle / request acceptance
        // ====================================================

        ST_READY: begin
            if (rstart && count != 0) begin
                transfer_lba <= (card_type == SDHCv2) ?
                                startLba : (startLba << 9);

                transfer_count <= count;
                sectors_done <= 0;
                rerror       <= 1'b0;

                retry_count   <= 0;
                retry_idle    <= 0;
                retry_timeout <= 0;

                byte_addr <= 0;
                outaddr <= 0;

                token_wait <= 0;
                nibble_count <= 0;
                tail_count <= 0;

                state <= ST_CMD18_START;
            end else if (rstart && count == 0) begin
                rerror <= 1'b0;
                state <= ST_READ_DONE;
            end
        end

        // ====================================================
        // CMD18: start multi-block read
        // ====================================================

        ST_CMD18_START: begin
            if (!busy) begin
                set_cmd(1, 16, 18, transfer_lba);
                state <= ST_CMD18_WAIT;
            end
        end

        ST_CMD18_WAIT: begin
            if (done) begin
                if (!timeout && !syntaxe) begin
                    token_wait <= 0;
                    nibble_count <= 0;
                    state <= ST_DATA_WAIT;
                end else begin
                    rerror <= 1'b1;
                    state  <= ST_READ_DONE;
                end
            end
        end

        // ====================================================
        // Wait for the next block's start token
        // ====================================================

        ST_DATA_WAIT: begin
            if (sd_rising) begin
                if (sddat == 4'b0000) begin
                    token_wait <= 0;
                    nibble_count <= 0;

                    state <= ST_DATA_READ;
                end else if (token_wait >= TOKEN_TIMEOUT) begin
                    // No data token arrived.  Retry the chunk silently a couple
                    // of times before reporting a hard error; a marginal card
                    // often succeeds on a second attempt.  The first retry also
                    // drops back to the proven default-speed clock, which is
                    // always legal and gives a struggling card more margin.
                    if (retry_count < 2'd2) begin
                        if (retry_count == 2'd0)
                            clkdiv <= FASTCLKDIV;
                        retry_count <= retry_count + 1'b1;
                        state <= ST_RETRY_START;
                    end else begin
                        rerror <= 1'b1;
                        state  <= ST_CMD12_START;
                    end
                end else begin
                    token_wait <= token_wait + 1'b1;
                end
            end
        end

        // ====================================================
        // Read 512 bytes, four data bits per SD clock
        // ====================================================

        ST_DATA_READ: begin
            if (sd_rising) begin

                if (!nibble_count[0]) begin
                    // First nibble: bits 7:4.
                    outbyte[7:4] <= sddat;
                end else begin
                    // Second nibble: bits 3:0, so one whole byte is available.
                    outbyte[3:0] <= sddat;

                    // Emit one byte at the global transfer offset.
                    outen   <= 1'b1;
                    outaddr <= byte_addr[15:0];

                    byte_addr <= byte_addr + 1'b1;

                end

                if (nibble_count == 10'd1023) begin
                    // 512 bytes received. Next comes the CRC.
                    tail_count <= 0;
                    state <= ST_DATA_TAIL;
                end else begin
                    nibble_count <= nibble_count + 1'b1;
                end
            end
        end

        // ====================================================
        // Skip CRC16 and end-of-block timing
        // ====================================================

        ST_DATA_TAIL: begin
            if (sd_rising) begin
                if (tail_count >= 8'd17) begin

                    if (sectors_done == transfer_count - 1'b1) begin
                        // All requested sectors received.
                        state <= ST_CMD12_START;
                    end else begin
                        sectors_done <= sectors_done + 1'b1;

                        token_wait <= 0;
                        nibble_count <= 0;

                        // CMD18 continues without another command.
                        state <= ST_DATA_WAIT;
                    end

                end else begin
                    tail_count <= tail_count + 1'b1;
                end
            end
        end

        // ====================================================
        // CMD12: stop transmission
        // ====================================================

        ST_CMD12_START: begin
            if (!busy) begin
                set_cmd(1, 16, 12, 32'h00000000);
                state <= ST_CMD12_WAIT;
            end
        end

        ST_CMD12_WAIT: begin
            if (done) begin
                if (timeout || syntaxe)
                    rerror <= 1'b1;
                // Stop command has completed.
                state <= ST_READ_DONE;
            end
        end

        // ====================================================
        // Silent retry: stop, let the bus go idle, re-read
        // ====================================================

        ST_RETRY_START: begin
            if (!busy) begin
                retry_timeout <= 0;
                set_cmd(1, 16, 12, 32'h00000000);
                state <= ST_RETRY_WAIT;
            end
        end

        ST_RETRY_WAIT: begin
            if (done) begin
                retry_idle <= 0;
                state <= ST_RETRY_IDLE;
            end
        end

        ST_RETRY_IDLE: begin
            if (sd_rising) begin
                retry_timeout <= retry_timeout + 1'b1;

                if (retry_timeout >= 16'hFFFF) begin
                    // The card is holding the bus; stop retrying and finish so
                    // the IOP still gets its completion interrupt.
                    rerror <= 1'b1;
                    state  <= ST_READ_DONE;
                end else if (sddat == 4'b1111) begin
                    if (retry_idle >= 8'd32) begin
                        // Bus is quiet: rewind the chunk and start over.
                        retry_idle     <= 0;
                        sectors_done   <= 0;
                        byte_addr      <= 0;
                        outaddr        <= 0;
                        nibble_count   <= 0;
                        token_wait     <= 0;
                        tail_count     <= 0;
                        state <= ST_CMD18_START;
                    end else begin
                        retry_idle <= retry_idle + 1'b1;
                    end
                end else begin
                    retry_idle <= 0;
                end
            end
        end

        // ====================================================
        // Completion
        // ====================================================

        ST_READ_DONE: begin
            state <= ST_READY;
        end

        default: begin
            state <= ST_CMD0;
        end

        endcase
    end
end

endmodule