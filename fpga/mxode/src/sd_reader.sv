module sd_reader #(
    parameter [2:0] CLK_DIV = 3'd1,
    parameter       SIMULATE = 0
)(
    input  wire        rstn,
    input  wire        clk,

    output wire        sdclk,
    inout              sdcmd,
    input  wire [3:0]  sddat,

    output wire [4:0]  card_stat,
    output reg  [1:0]  card_type,

    input  wire        rstart,
    input  wire [31:0] startLba,
    input  wire [31:0] count,

    output wire        rbusy,
    output wire        rdone,

    output reg         outen,
    output reg  [15:0] outaddr,
    output reg  [7:0]  outbyte
);

localparam [1:0] UNKNOWN = 2'd0,
                 SDv1    = 2'd1,
                 SDv2    = 2'd2,
                 SDHCv2  = 2'd3;

localparam [15:0] FASTCLKDIV = 16'd1 << CLK_DIV;
localparam [15:0] SLOWCLKDIV =
    FASTCLKDIV * (SIMULATE ? 16'd2 : 16'd48);

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

    ST_READ_DONE   = 5'd18;

reg [4:0] state = ST_CMD0;

assign card_stat = state;

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

reg [8:0]  block_byte_idx = 0;
reg [31:0] byte_addr = 0;

wire sd_rising = !sdclkl && sdclk;

// ------------------------------------------------------------
// Command controller instance
// ------------------------------------------------------------

sdcmd_ctrl sdcmd_ctrl_i (
    .rstn     (rstn),
    .clk      (clk),
    .sdclk    (sdclk),
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
        block_byte_idx <= 0;
        byte_addr      <= 0;

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
                if (!timeout && !syntaxe)
                    state <= ST_READY;
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

                byte_addr <= 0;
                outaddr <= 0;

                token_wait <= 0;
                nibble_count <= 0;
                tail_count <= 0;
                block_byte_idx <= 0;

                state <= ST_CMD18_START;
            end else if (rstart && count == 0) begin
                state <= ST_READ_DONE;
            end
        end

        // ====================================================
        // CMD18: start multi-block read
        // ====================================================

        ST_CMD18_START: begin
            if (!busy) begin
                set_cmd(1, 96, 18, transfer_lba);
                state <= ST_CMD18_WAIT;
            end
        end

        ST_CMD18_WAIT: begin
            if (done) begin
                if (!timeout && !syntaxe) begin
                    token_wait <= 0;
                    nibble_count <= 0;
                    block_byte_idx <= 0;
                    state <= ST_DATA_WAIT;
                end else begin
                    state <= ST_READ_DONE;
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
                    block_byte_idx <= 0;

                    state <= ST_DATA_READ;
                end else if (token_wait >= TOKEN_TIMEOUT) begin
                    // Abort the multiblock operation.
                    state <= ST_CMD12_START;
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
                    // Second nibble: bits 3:0.
                    outbyte[3:0] <= sddat;

                    // Emit one byte at the global transfer offset.
                    outen   <= 1'b1;
                    outaddr <= byte_addr[15:0];

                    byte_addr <= byte_addr + 1'b1;

                    block_byte_idx <= block_byte_idx + 1'b1;
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
                        block_byte_idx <= 0;

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
                set_cmd(1, 96, 12, 32'h00000000);
                state <= ST_CMD12_WAIT;
            end
        end

        ST_CMD12_WAIT: begin
            if (done) begin
                // Stop command has completed.
                state <= ST_READ_DONE;
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