module mxode_top(
	 input wire clk,
     input wire dma_clk,

	 inout wire [15:0] ps2_addr,
     inout wire [15:0] ps2_data,
	 output wire HDRQ,
	 input wire HACK,
	 output wire HINT,

	 input wire dsp_rd,
	 input wire dsp_wr,
	 input wire dsp_cs_in,
	 
	 input wire scopro_mosi,
	 input wire scopro_sck,
	 input wire scopro_cs,
	 output wire scopro_miso,
	 output wire scopro_irq,
	 
	 output wire sd_clk,
	 inout wire sd_cmd,
	 input wire [3:0] sd_dat,
     output wire act_led

);/*
wire clk27;
Gowin_rPLL mainPll(
        .clkout(clk27), //output clkout
        .clkin(clk) //input clkin
    );*/
wire clk27;
Gowin_rPLL mainPll(
        .clkout(clk27), //output clkout
        .clkin(clk) //input clkin
    );
reg [26:0] sd_reset_counter = 25'd0;
reg sd_rstn = 1'b0;

always @(posedge clk27) begin
        if (sd_reset_counter == 27'd99_999_999) begin
            sd_rstn <= 1'b1;
        end else begin
            sd_reset_counter <= sd_reset_counter + 1'b1;
        end
end
wire [7:0] sdOut;
wire [10:0] sdAddr;
wire sdWr;

wire readSectorStart;
wire readSectorDone;
wire [31:0] sector_lba;
wire sd_busy;
wire [3:0] card_stat;
wire [3:0] card_type;
sd_reader #(
    .CLK_DIV(3'd1),
    .SIMULATE(0)
) sd_reader_inst (
    .rstn     (sd_rstn),
    .clk      (clk27),
    .sdclk    (sd_clk),
    .sdcmd    (sd_cmd),
    .sddat   (sd_dat),
    .card_stat(card_stat),
    .card_type(card_type),
    .rstart   (readSectorStart),
    .rsector  (sector_lba),
    .rbusy    (sd_busy),
    .rdone    (readSectorDone),
    .outen    (sdWr),
    .outaddr  (sdAddr),
    .outbyte  (sdOut)
);


assign act_led = !sd_busy & !sError;


wire dspActive = !(dsp_cs_in & !HACK);
wire dspWrite = dspActive & !dsp_wr;
wire dspRead = dspActive  & !dsp_rd ;

wire isScommandSegment = (ps2_addr[7:0] > 8'h15) & (ps2_addr[7:0] < 8'h19); 
wire isNcommandSegment = !isScommandSegment;

wire updateSticky;
wire [7:0] sDataOut;
wire sError;
sCommandProcessor sProcInst(
    .clk(clk27),
    .en(isScommandSegment),
    .dspWrite,
    .dspRead,

    .updateSticky(updateSticky),
    .addressIn(ps2_addr[7:0]),
    .dataIn(ps2_data[7:0]),
    .dataOut(sDataOut),
    .error(sError),

    .scopro_cs,
    .scopro_sck,
    .scopro_mosi,
    .scopro_miso,
    .scopro_irq
);

wire [7:0] nDataOut;
wire irq;
assign HINT = !irq;

wire [31:0] dmaDataOut;
nCommandProcessor nProc(
		.clk(clk27),
		.dma_clk(dma_clk),
		
		.en(isNcommandSegment & !HACK),
		.addr(ps2_addr[7:0]),
        
        .dspRead,
        .dspWrite,
        .cs_raw(dsp_cs_in),
        .rd_raw(dsp_rd),
		.updateSticky(updateSticky),
		.dataIn(ps2_data),
		.dataOut(nDataOut),
		
		.irq(irq),
		.dma_ack(HACK),
        .dma_req(HDRQ),
		.dmaDataOut(dmaDataOut),
		
		.sdDataIn(sdOut),
		.sdAddrIn(sdAddr),
		.sdWr(sdWr),
		.readSectorStart(readSectorStart),
        .readSectorDone(readSectorDone),
		.readSectorLba(sector_lba),
		.sd_busy(sd_busy)


);

assign ps2_addr = HACK ? dmaDataOut[31:16] : 16'bzzzz;
assign ps2_data = HACK ? dmaDataOut[15:0] : 
                  (dspRead && isScommandSegment) ? sDataOut : 
                  (dspRead && isNcommandSegment) ? nDataOut :
                  //(dspRead && ps2_addr[7:0] == 8'h05) ? {1'b0,1'b1,2'b0,1'b1,3'b0} :

                  //(dspRead) ? 16'h00 :
                  16'bzzzz;/*
                  (dspRead && ps2_addr[7:0] == 8'h05) ? {1'b0,1'b1,2'b0,1'b1,3'b0} :
                  (dspRead) ? 16'h00:
                  (dspRead && isNcommandSegment) ? nDataOut :

						//(dspRead && isNcommandSegment) ? nDataOut :
                  16'bz;*/

endmodule