module sCommandProcessor(
    input wire clk,
    input wire en,
    input wire dspWrite,
    input wire dspRead,

    output logic updateSticky,
    input wire [7:0] addressIn,
    input wire [7:0] dataIn,
    output logic [7:0] dataOut,
    output wire error,

    input wire scopro_cs,
    input wire scopro_sck,
    input wire scopro_mosi,
    output wire scopro_miso,
    output wire scopro_irq
);
reg unknownCmd = 1'b0;
assign error = unknownCmd;
reg spi_request = 1'b0;
wire spi_busy;
wire spi_ready;
wire spi_error;

reg  [7:0] spi_tx [0:19];
wire [7:0] spi_rx [0:19];
reg [4:0] spiTransferLen;

stm32_interface stm32_interface_inst (
    .clk            (clk),
    
    .stm32_cs       (scopro_cs),
    .stm32_sck      (scopro_sck),
    .stm32_mosi     (scopro_mosi),
    .stm32_miso     (scopro_miso),
    .stm32_irq      (scopro_irq),

    .spi_request    (spi_request),
    .spi_busy       (spi_busy),
    .spi_ready      (spi_ready),
    .spi_error      (spi_error),

    .spiDataOut     (spi_tx),
    .spiTransferLen (spiTransferLen),
    .spiDataIn      (spi_rx)
);

reg [7:0] activeSCommand;
reg [7:0] responseBuffer [0:31];
reg [7:0] paramBuffer[0:15];
reg [4:0] paramWriteIndex = 5'd0;
reg [7:0] responseRdIndex;
reg [7:0] responseLength;
reg sComTakenOver;


wire dspWrite_sync;
wire writeRising;
wire writeFalling;
syncEdgeDetect writeSync(
	.clk(clk),
	.signal(dspWrite),
	.sync(dspWrite_sync),
	.rising(writeRising),
	.falling(writeFalling)

);

wire dspRd_sync;

wire readFalling;

syncEdgeDetect readSync(
	.clk(clk),
	.signal(dspRead),
	.sync(dspRd_sync),
	.falling(readFalling)

);

always @(posedge clk) begin
	updateSticky <=0;
    spi_request <= 0;
    
    if (spi_ready) begin
        if (activeSCommand == 8'h41) begin
            for (integer i = 0; i < 19; i = i + 1)
                responseBuffer[i] <= spi_rx[i + 1];
        end else begin
            responseBuffer[0] <= spi_error ? 8'h01 : 8'h00;

            for (integer i = 1; i < 20; i = i + 1)
                responseBuffer[i] <= spi_rx[i];
        end
    end

/*if(!system_on) begin 
		sComTakenOver <=0;
		activeSCommand <= 0;
	end*/

    if(en & !spi_busy) begin
    // Accept S-command writes
        if (writeRising) begin
            case (addressIn)
				8'hff: activeSCommand <= dataIn; // to prevent turning into m9k!!
                8'h16: begin   // issue Scommand
					paramWriteIndex <= 0;
					responseRdIndex <= 0;
					case (dataIn)
						8'h03: begin 
							activeSCommand <= 8'h03;
							responseLength <= 4;
							responseBuffer[0] <= 8'h00;
							responseBuffer[1] <= 8'h02;
							responseBuffer[2] <= 8'h06;
							responseBuffer[3] <= 8'h03;
							sComTakenOver <= 1'b1;
						end
						8'h05: begin //updateSticky
							activeSCommand <= 8'h05;
							responseLength <= 1;
							responseBuffer[0] <= 0;
							sComTakenOver <= 1'b1;
							updateSticky<= 1;
						end
						8'h08: begin 
							activeSCommand <= 8'h08;
							responseLength <= 8;
                            spi_request <=1;
							//spi_busy <= 1;
							spiTransferLen <= 9;
							spi_tx[0] <= dataIn;
							//responseBuffer[0] <= 8'hff;
							//responseBuffer[1] <= 8'hff;
							//responseBuffer[2] <= 8'hff;
							//responseBuffer[3] <= 8'hff;
							//responseBuffer[4] <= 8'hff;
							//responseBuffer[5] <= 8'hff;
							//responseBuffer[6] <= 8'hff;
							//responseBuffer[7] <= 8'hff;
							sComTakenOver <= 1'b1;
						end
						8'h15: begin
							activeSCommand <= 8'h15;
							responseLength <= 1;
							responseBuffer[0] <= 8'h05;
							sComTakenOver <= 1'b1;
						end
						8'h17: begin
							 activeSCommand <= 8'h17;
							 responseLength <= 9;
							 responseBuffer[0] <= 8'h00;
							 responseBuffer[1] <= 8'h52;
							 responseBuffer[2] <= 8'h37;
							 responseBuffer[3] <= 8'h35;
							 responseBuffer[4] <= 8'h33;
							 responseBuffer[5] <= 8'h31;
							 responseBuffer[6] <= 8'h0a;
							 responseBuffer[7] <= 8'h00;
							 responseBuffer[8] <= 8'h00;
							 
							 sComTakenOver <= 1'b1;
						end
						8'h1A: begin
							 activeSCommand <= 8'h1A;
							 responseLength <= 1;
							 responseBuffer[0] <= 8'h01;
							 sComTakenOver <= 1'b1;
						end

						8'h1e: begin
							activeSCommand <= 8'h1e;
							responseLength <= 5;
							responseBuffer[0] <= 8'h00;
							responseBuffer[1] <= 8'h14;
							responseBuffer[2] <= 8'h00;
							responseBuffer[3] <= 8'h00;
							responseBuffer[4] <= 8'h00;
							sComTakenOver <= 1'b1;
						end
						8'h36: begin
							activeSCommand <= 8'h36;
							responseLength <= 15;

                            spi_request <=1;
							//spi_busy <= 1;
							spiTransferLen <= 16;
							spi_tx[0] <= dataIn;
                            sComTakenOver <= 1'b1;
						end
						8'h37: begin
							 activeSCommand <= 8'h37;
							 responseLength <= 9;

							spi_request <=1;
							//spi_busy <= 1;
							spiTransferLen <= 10;
							spi_tx[0] <= dataIn;

							 sComTakenOver <= 1'b1;
						end
						
						8'h40: begin
							 activeSCommand <= 8'h40;
							 responseLength <= 1;

							 spi_request <=1;
							 spiTransferLen <= 5;
							 spi_tx[0] <= dataIn;
							 spi_tx[1]  <= paramBuffer[0];
							 spi_tx[2]  <= paramBuffer[1];
							 spi_tx[3]  <= paramBuffer[2];
							 sComTakenOver <= 1'b1;
						end
						8'h41: begin
							 activeSCommand <= 8'h41;
							 responseLength <= 16;
							 spi_request <= 1;
							 spiTransferLen <= 18;
							 spi_tx[0] <= dataIn;
							 sComTakenOver <= 1'b1;
						end
						8'h42: begin
							 activeSCommand <= 8'h42;
							 responseLength <= 1;
							 responseBuffer[0] <= 8'h00;
							 sComTakenOver <= 1'b1;
						end
						
						8'h43: begin
							 activeSCommand <= 8'h43;
							 responseLength <= 1;
							 spi_request <=1;
							 spiTransferLen <= 2;
							 spi_tx[0] <= dataIn;
							 sComTakenOver <= 1'b1;
						end
						8'h80: begin 
							activeSCommand <= dataIn;
							responseLength <= 1;
							responseBuffer[0] <= 8'h00;

							 //if (dataIn == 8'h80 || dataIn == 8'h81)
								//  mg_datatype <= 0;
							spi_request <=1;
							//spi_busy <= 1;
							spiTransferLen <= 2;
							spi_tx[0] <= dataIn;
							sComTakenOver <= 1'b1;
						end
						8'h82: begin //params hold the challenge 
							activeSCommand <= dataIn;
							 responseLength <= 1;
							 spiTransferLen <= 18;
							 spi_request<=1;
							 //spi_busy<=1;
							 spi_tx[0] <= dataIn;
							 
							spi_tx[1]  <= paramBuffer[0];
							spi_tx[2]  <= paramBuffer[1];
							spi_tx[3]  <= paramBuffer[2];
							spi_tx[4]  <= paramBuffer[3];
							spi_tx[5]  <= paramBuffer[4];
							spi_tx[6]  <= paramBuffer[5];
							spi_tx[7]  <= paramBuffer[6];
							spi_tx[8]  <= paramBuffer[7];
							spi_tx[9]  <= paramBuffer[8];
							spi_tx[10] <= paramBuffer[9];
							spi_tx[11] <= paramBuffer[10];
							spi_tx[12] <= paramBuffer[11];
							spi_tx[13] <= paramBuffer[12];
							spi_tx[14] <= paramBuffer[13];
							spi_tx[15] <= paramBuffer[14];
							spi_tx[16]  <= paramBuffer[15];
														sComTakenOver <= 1;

						
						end
						8'h83: begin // params hold nonce
							activeSCommand <= dataIn;
							 responseLength <= 1;
							 spiTransferLen <= 10;
							 spi_request<=1;
							 //spi_busy<=1;
							 spi_tx[0] <= dataIn;
							 
							spi_tx[1]  <= paramBuffer[0];
							spi_tx[2]  <= paramBuffer[1];
							spi_tx[3]  <= paramBuffer[2];
							spi_tx[4]  <= paramBuffer[3];
							spi_tx[5]  <= paramBuffer[4];
							spi_tx[6]  <= paramBuffer[5];
							spi_tx[7]  <= paramBuffer[6];
							spi_tx[8]  <= paramBuffer[7];
							sComTakenOver <= 1;
							 
						end
						
						8'h84: begin
							 activeSCommand <= 8'h84;
							 responseLength <= 13;
							 
							 spiTransferLen <= 14;
							 spi_request<=1;
							 //spi_busy<=1;
							 spi_tx[0] <= dataIn;
							 sComTakenOver <= 1'b1;
						end
						8'h85: begin
							 activeSCommand <= 8'h85;
							 responseLength <= 13;
							 spiTransferLen <= 14;
							 spi_request<=1;
							 //spi_busy<=1;
							 spi_tx[0] <= dataIn;
							 sComTakenOver <= 1'b1;
						end
						8'h86: begin 
							activeSCommand <= 8'h86;
							responseLength <= 1;
							spiTransferLen <= 18;
							spi_request<=1;
							 //spi_busy<=1;
							 spi_tx[0] <= dataIn;
							 spi_tx[1]  <= paramBuffer[0];
							spi_tx[2]  <= paramBuffer[1];
							spi_tx[3]  <= paramBuffer[2];
							spi_tx[4]  <= paramBuffer[3];
							spi_tx[5]  <= paramBuffer[4];
							spi_tx[6]  <= paramBuffer[5];
							spi_tx[7]  <= paramBuffer[6];
							spi_tx[8]  <= paramBuffer[7];
							spi_tx[9]  <= paramBuffer[8];
							spi_tx[10] <= paramBuffer[9];
							spi_tx[11] <= paramBuffer[10];
							spi_tx[12] <= paramBuffer[11];
							spi_tx[13] <= paramBuffer[12];
							spi_tx[14] <= paramBuffer[13];
							spi_tx[15] <= paramBuffer[14];
							spi_tx[16]  <= paramBuffer[15];
							 sComTakenOver <= 1'b1;
						end
						8'h87: begin
							activeSCommand <= dataIn;
							 responseLength <= 1;
							 spiTransferLen <= 10;
							 spi_request<=1;
							 //spi_busy<=1;
							 spi_tx[0] <= dataIn;
							 
							spi_tx[1]  <= paramBuffer[0];
							spi_tx[2]  <= paramBuffer[1];
							spi_tx[3]  <= paramBuffer[2];
							spi_tx[4]  <= paramBuffer[3];
							spi_tx[5]  <= paramBuffer[4];
							spi_tx[6]  <= paramBuffer[5];
							spi_tx[7]  <= paramBuffer[6];
							spi_tx[8]  <= paramBuffer[7];
							sComTakenOver <= 1;
							 
						end
						
						8'h88: begin 
							activeSCommand <= dataIn;
							responseLength <= 1;
							responseBuffer[0] <= 8'h00;

							 //if (dataIn == 8'h80 || dataIn == 8'h81)
								//  mg_datatype <= 0;
							//spi_request <=1;
							//spi_busy <= 1;
							//spiTransferLen <= 2;
							//spi_tx[0] <= dataIn;
							sComTakenOver <= 1'b1;
							
						end
						
						8'h81: begin
							 
							 activeSCommand <= dataIn;
							 responseLength <= 1;
							 responseBuffer[0] <= 8'h00;

							 //if (dataIn == 8'h80 || dataIn == 8'h81)
								//  mg_datatype <= 0;

							 sComTakenOver <= 1'b1;
						end
						
						

					
						
						8'h8D: begin
							 activeSCommand <= dataIn;
							 responseLength <= 1;

							 //if (mg_size + paramWriteIndex > mg_maxsize) begin
								//  responseBuffer[0] <= 8'h80;
							 //end else begin
								  //for (integer i = 0; i < 16; i = i + 1) begin
										//if (i < paramWriteIndex)
									//		 mg_buffer[mg_size + i] <= paramBuffer[i];
								  //end

								//  mg_size <= mg_size + paramWriteIndex;
								  responseBuffer[0] <= 8'h00;
							 //end

							 sComTakenOver <= 1'b1;
						end
												
						8'h8E: begin
							 activeSCommand <= 8'h8E;
							 responseLength <= 16;//(mg_size < 16) ? mg_size : 16;
							 responseBuffer[0] <= 8'h00;
							 responseBuffer[1] <= 8'h00;
							 responseBuffer[2] <= 8'h00;
							 responseBuffer[3] <= 8'h00;
							 responseBuffer[4] <= 8'h00;
							 responseBuffer[5] <= 8'h00;
							 responseBuffer[6] <= 8'h00;
							 responseBuffer[7] <= 8'h00;
							 responseBuffer[8] <= 8'h00;
							 responseBuffer[9] <= 8'h00;
							 responseBuffer[10] <= 8'h00;
							 responseBuffer[11] <= 8'h00;
							 responseBuffer[12] <= 8'h00;
							 responseBuffer[13] <= 8'h00;
							 responseBuffer[14] <= 8'h00;
							 responseBuffer[15] <= 8'h00;
							 

							 //for (integer i = 0; i < 1008; i = i + 1)
								//  mg_buffer[i] <= mg_buffer[i + 16];

							 //mg_size <= (mg_size < 16) ? 0 : mg_size - 16;

							 sComTakenOver <= 1'b1;
						end

						8'h8F: begin
							 activeSCommand <= 8'h8F;
							 responseLength <= 1;
							 responseBuffer[0] <= 8'h00;
							 sComTakenOver <= 1'b1;
						end
					
					default: begin 
						activeSCommand <= dataIn;
						responseLength <= 1;
						spiTransferLen <= 2;
						spi_request<=1;
                        unknownCmd <= 1;
                        spi_tx[0] <= dataIn;
						sComTakenOver <= 1'b0;

					/*
							commandThatCausedErr <=dataIn;
							errorState <= 1;
							responseLength <= 0;
							activeSCommand <= 0;
							sComTakenOver <= 1'b0;
					*/
					end
					endcase

            end
				8'h17: begin // write param
					if (paramWriteIndex < 5'd16) begin
						  paramBuffer[paramWriteIndex[3:0]] <= dataIn;
						  paramWriteIndex <= paramWriteIndex + 1'b1;
					 end
				end
        endcase
    end
	
	 end
    // Detect the end of a read cycle
    if (en & readFalling && sComTakenOver && (addressIn == 8'h18)) begin
        if (responseRdIndex == responseLength - 1'b1) begin
            responseRdIndex <= 0;
            sComTakenOver <= 1'b0;
        end else begin
            responseRdIndex <= responseRdIndex + 1'b1;
        end
    end

	 
end

always_comb begin
    case (addressIn) 
        8'h16: dataOut <= activeSCommand;
        8'h17: dataOut <= {spi_busy,(!sComTakenOver)|spi_busy,6'b0};
        8'h18: dataOut <= responseBuffer[responseRdIndex];
        default: dataOut <= 8'hff;
    endcase
end


endmodule