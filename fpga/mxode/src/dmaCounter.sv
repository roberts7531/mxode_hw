module dmaCounter(
    input wire dma_clk,
    input wire dsp_cs,
    input wire dma_ack,

    output wire [31:0] dmaCurrentByte


);
assign dmaCurrentByte = dmaByteCount;//(dma_ack) ? dmaByteCount : 32'h0;
logic [31:0] dmaByteCount;

always @(negedge dma_clk) begin 
    if ( dsp_cs & !dma_ack) begin
        dmaByteCount <= 32'hffffffff;
    end else begin
        dmaByteCount <= dmaByteCount + 1'b1;
    end
end

endmodule