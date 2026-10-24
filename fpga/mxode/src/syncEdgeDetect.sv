module syncEdgeDetect(
	input wire clk,
	input wire signal,
	output logic sync,
	output wire rising,
	output wire falling

);
logic sync2;
logic prev;


always @(posedge clk) begin 
	sync2 <= signal;
	sync <= sync2;
	prev <= sync2;
end

assign rising = sync2 & !prev;
assign falling = !sync2 & prev;
endmodule