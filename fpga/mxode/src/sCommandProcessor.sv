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
    output wire scopro_irq,
    
    input wire sdReady,
    input wire sdError,
    input wire sdInitialized,   // card identification already completed
    output logic sdReset
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
    sdReset <= 1'b0;

    if (spi_ready) begin
        if (activeSCommand == 8'h41) begin
            for (integer i = 0; i < 19; i = i + 1)
                responseBuffer[i] <= spi_rx[i + 1];
        end else if ((activeSCommand == 8'h15) || (activeSCommand == 8'h1A)) begin
            // These commands return their single data byte without a status prefix.
            responseBuffer[0] <= spi_rx[1];
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
                    activeSCommand <= dataIn;
					case (dataIn)
						8'h03: begin
							responseLength <= 4;
							spi_request <= 1;
							spiTransferLen <= 5;
							spi_tx[0] <= dataIn;
							sComTakenOver <= 1'b1;
						end
						8'h05: begin //updateSticky
							responseLength <= 1;
							responseBuffer[0] <= 0;
							sComTakenOver <= 1'b1;
							updateSticky<= 1;
						end
						8'h08: begin 
							responseLength <= 8;
                            spi_request <=1;
							spiTransferLen <= 9;
							spi_tx[0] <= dataIn;
							sComTakenOver <= 1'b1;
						end
						8'h15: begin
							responseLength <= 1;
							spi_request <= 1;
							spiTransferLen <= 3;
							spi_tx[0] <= dataIn;
							sComTakenOver <= 1'b1;
						end
						8'h17: begin
							 responseLength <= 9;
							 spi_request <= 1;
							 spiTransferLen <= 10;
							 spi_tx[0] <= dataIn;
							 sComTakenOver <= 1'b1;
						end
						8'h1A: begin
							 responseLength <= 1;
							 spi_request <= 1;
							 spiTransferLen <= 3;
							 spi_tx[0] <= dataIn;
							 sComTakenOver <= 1'b1;
						end

						8'h1e: begin
							responseLength <= 5;
							spi_request <= 1;
							spiTransferLen <= 6;
							spi_tx[0] <= dataIn;
							sComTakenOver <= 1'b1;
						end
						8'h36: begin
							responseLength <= 15;
                            spi_request <=1;
							spiTransferLen <= 16;
							spi_tx[0] <= dataIn;
                            sComTakenOver <= 1'b1;
						end
						8'h37: begin
							responseLength <= 9;
							spi_request <=1;
							spiTransferLen <= 10;
							spi_tx[0] <= dataIn;
							sComTakenOver <= 1'b1;
						end
						
						8'h40: begin
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
							 responseLength <= 16;
							 spi_request <= 1;
							 spiTransferLen <= 18;
							 spi_tx[0] <= dataIn;
							 sComTakenOver <= 1'b1;
						end
						8'h42: begin
							 responseLength <= 1;
							 spi_request <= 1;
							 spiTransferLen <= 2;
							 spi_tx[0] <= dataIn;
							 sComTakenOver <= 1'b1;
						end
						
						8'h43: begin
							 responseLength <= 1;
							 spi_request <=1;
							 spiTransferLen <= 2;
							 spi_tx[0] <= dataIn;
							 sComTakenOver <= 1'b1;
						end
						8'h80: begin 
							responseLength <= 1;
							responseBuffer[0] <= 8'h00;
							spi_request <=1;
							spiTransferLen <= 2;
							spi_tx[0] <= dataIn;
							sComTakenOver <= 1'b1;
						end
						8'h82: begin //params hold the challenge 
							responseLength <= 1;
							spiTransferLen <= 18;
							spi_request<=1;
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
							 responseLength <= 1;
							 spiTransferLen <= 10;
							 spi_request<=1;
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
							 responseLength <= 13;
							 spiTransferLen <= 14;
							 spi_request<=1;
							 spi_tx[0] <= dataIn;
							 sComTakenOver <= 1'b1;
						end
						8'h85: begin
							 responseLength <= 13;
							 spiTransferLen <= 14;
							 spi_request<=1;
							 spi_tx[0] <= dataIn;
							 sComTakenOver <= 1'b1;
						end
						8'h86: begin 
							responseLength <= 1;
							spiTransferLen <= 18;
							spi_request<=1;
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
							responseLength <= 1;
							spiTransferLen <= 10;
							spi_request<=1;
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
							responseLength <= 1;
							spi_request <= 1;
							spiTransferLen <= 2;
							spi_tx[0] <= dataIn;
							sComTakenOver <= 1'b1;
						end
						
						8'h81: begin
							 responseLength <= 1;
							 spi_request <= 1;
							 spiTransferLen <= 2;
							 spi_tx[0] <= dataIn;
							 sComTakenOver <= 1'b1;
						end

						8'h8D: begin
							 responseLength <= 1;
							 spi_request <= 1;
							 spiTransferLen <= 2;
							 spi_tx[0] <= dataIn;
							 sComTakenOver <= 1'b1;
						end
												
						8'h8E: begin
							 responseLength <= 16;
							 spi_request <= 1;
							 spiTransferLen <= 17;
							 spi_tx[0] <= dataIn;
							 sComTakenOver <= 1'b1;
						end

						8'h8F: begin
							 responseLength <= 1;
							 spi_request <= 1;
							 spiTransferLen <= 2;
							 spi_tx[0] <= dataIn;
							 sComTakenOver <= 1'b1;
						end


                        8'hDE: begin // issue SDCARD reset 
                            responseLength <= 1'b1;
                            responseBuffer[0] <= 8'h00;
                            // Only take the link down when it is not usable.
                            // OPL reloads this driver inside the game's IOPRP at
                            // launch, and its _start sends 0xDE: resetting a
                            // healthy idle card there drops high-speed mode and
                            // can abort the loader, which froze the game.  A
                            // real fault (sdError) or an in-flight transfer
                            // (sdReady low) still gets a full reset.
                            if (sdInitialized && sdReady && !sdError)
                                sdReset <= 1'b0;
                            else
                                sdReset <= 1'b1;
                            sComTakenOver <= 1'b1;
                        end
                        8'hDF: begin 
                            responseLength <= 1'b1;
                            // bit0: SD state machine idle and card initialised
                            // bit1: the last multi-block read hit a hard error
                            //       (insertion/removal detection; older
                            //       bitstreams leave this bit clear)
                            responseBuffer[0] <= {6'h0,sdError,sdReady};
                            sComTakenOver <= 1'b1;
                        end
					
                        default: begin 
                            responseLength <= 1;
                            spiTransferLen <= 2;
                            spi_request<=1;
                            unknownCmd <= 1;
                            spi_tx[0] <= dataIn;
                            sComTakenOver <= 1'b0;
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