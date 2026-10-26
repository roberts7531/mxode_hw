module nCommandProcessor(
    	input wire clk,
		input wire dma_clk,
		input wire en,
		input wire [7:0] addr,
		
        input wire dspRead,
        input wire dspWrite,
		
		input wire updateSticky,
		input wire [7:0] dataIn,
		output reg [7:0] dataOut,

		
		output wire irq,
		input wire cs_raw,
        input wire rd_raw,
		output reg dma_req,
		input  wire dma_ack,
		output wire dma_has_bus,
		output reg [31:0] dmaDataOut,
		input wire [7:0] sdDataIn,
		input wire [15:0] sdAddrIn,
		input wire sdWr,
		output reg readSectorStart,
        input wire readSectorDone,
		output reg [31:0] readSectorLba,
        output reg [31:0] sdReadCount,

		input wire sd_busy,

        input wire [31:0] dmaByteCount

);
import ps2_types_pkg::*;

logic [7:0] activeNCommand;
logic [7:0] intrStatus =8'h00;
logic [7:0] stickyStatus;
logic [7:0] discStatus;
logic [7:0] cdvd_key [0:15];
logic [7:0] key_xor;
logic [7:0] nCommandParams[16];
logic [3:0] paramWrIndex;
logic [7:0] nCommandTried;
assign irq = |intrStatus;



always @(posedge clk) if (updateSticky) stickyStatus <= discStatus; //need to be OR'ed

wire dma_ack_falling;
wire ack_sync;
syncEdgeDetect dmaAckSync(
	.clk(clk),
	.signal(dma_ack),
	.falling(dma_ack_falling),
	.sync(ack_sync)
);
wire wrRising;
syncEdgeDetect wrSync(
    .clk(clk),
    .signal(dspWrite),
    .rising(wrRising)
);

wire dma_busy = currentDmaState != DMA_IDLE;
wire dma_busy_sync;
syncEdgeDetect dmaBusySync(
    .clk(clk),
    .signal(dma_busy),
    .rising(dma_busy_sync)
);

always_comb begin
    dataOut = 0;
    if (dspRead) begin
        case (addr)
            8'h04: // currentNCommand
                dataOut = activeNCommand;

            8'h05: // nCommandStatus
                dataOut = {1'b0,1'b1,2'b0,1'b1,3'b0};//8'b01001000;

            8'h06:
                dataOut = 0;

            8'h08:
                dataOut = intrStatus;

            8'h0A:
                dataOut = discStatus;

            8'h0B:
                dataOut = stickyStatus;

            8'h0F:
                dataOut = DISC_NO_DISC;

            // CDVD key registers: key bytes 0-4
            8'h20, 8'h21, 8'h22, 8'h23, 8'h24:
                dataOut = cdvd_key[addr - 8'h20];

            8'h28, 8'h29, 8'h2A, 8'h2B, 8'h2C:
                dataOut = cdvd_key[addr - 8'h23];

            8'h30, 8'h31, 8'h32, 8'h33, 8'h34:
                dataOut = cdvd_key[addr - 8'h26];

            8'h38: // KeysValid
                dataOut = cdvd_key[15];

            8'h39: // KeyXor
                dataOut = key_xor;

				8'he0: dataOut <= nCommandParams[0];
				8'he1: dataOut <= nCommandParams[1];
				8'he2: dataOut <= nCommandParams[2];
				8'he3: dataOut <= nCommandParams[3];
				8'he4: dataOut <= nCommandParams[4];
				8'he5: dataOut <= nCommandParams[5];
				8'he6: dataOut <= nCommandParams[6];
				8'he7: dataOut <= nCommandParams[7];
				8'he8: dataOut <= nCommandParams[8];
				8'he9: dataOut <= nCommandParams[9];
				8'hea: dataOut <= nCommandParams[10];
				8'heb: dataOut <= nCommandParams[11];
				8'hec: dataOut <= nCommandParams[12];
            default:
                dataOut = nCommandTried;
        endcase
    end
end
reg readScheduled;
reg [31:0] readSectorCount;
reg [31:0] readSectorsRemaining;
reg [31:0] sectorOffset;
reg dma_start;

// Effective BRAM write address
wire [14:0] bramWriteAddr = sdAddrIn + sectorOffset;
always @(posedge clk) begin 
	readSectorStart <= 0;
	if (en & !ack_sync) begin
		if(wrRising) begin 
			case(addr) 
				8'h4: begin 
					paramWrIndex <= 0;
					case(dataIn) 
						8'h0: begin 
							activeNCommand <= dataIn;
							intrStatus[0] <= 1;
							//dont touch ready
						end
						8'h6: begin 
							activeNCommand <= dataIn;
							intrStatus[0] <= 1;
							
						
						end
						
						8'h8: begin  //dvd sector read!
							if(!readScheduled) begin
								readScheduled <= 1;
								readSectorCount <= 1;
                                sdReadCount <= 1;
								readSectorLba <= {
									 nCommandParams[3],
									 nCommandParams[2],
									 nCommandParams[1],
									 nCommandParams[0]
								};
                                sectorOffset <= 0;
                                readSectorsRemaining <= 1;
								activeNCommand <= dataIn;
								intrStatus[0] <= 1;
							end
						end
						8'hc: begin 
							activeNCommand <= dataIn;
							intrStatus[0] <= 1;
							cdvd_key[0]  <= 8'h94;
							cdvd_key[1]  <= 8'h69;
							cdvd_key[2]  <= 8'h95;
							cdvd_key[3]  <= 8'h39;
							cdvd_key[4]  <= 8'h7D;
							cdvd_key[5]  <= 8'h00;
							cdvd_key[6]  <= 8'h00;
							cdvd_key[7]  <= 8'h00;
							cdvd_key[8]  <= 8'h00;
							cdvd_key[9]  <= 8'h00;
							cdvd_key[10] <= 8'h00;
							cdvd_key[11] <= 8'h00;
							cdvd_key[12] <= 8'h00;
							cdvd_key[13] <= 8'h00;
							cdvd_key[14] <= 8'hDC;
							cdvd_key[15] <= 8'h05;
							key_xor <= 0;
							discStatus <= 8'h0a;
						end
                       
                        8'hDD: begin //proper sd reader! 
                            if(!readScheduled) begin 
                                readScheduled <= 1;
								sdReadCount <= {
                                    nCommandParams[7],
                                    nCommandParams[6],
                                    nCommandParams[5],
                                    nCommandParams[4]
                                };
								readSectorLba <= {
									 nCommandParams[3],
									 nCommandParams[2],
									 nCommandParams[1],
									 nCommandParams[0]
								};
                              
                                sectorOffset <= 0;
								activeNCommand <= dataIn;
								intrStatus[0] <= 1;
    
                            end
                        end
						default: begin 
							activeNCommand <= 8'hff;
							nCommandTried <= dataIn;
						end
					endcase
				end
				
				8'h8: begin // write to 0x8, clear intr bit 
					intrStatus <= intrStatus & ~dataIn;
				end
				8'h05: begin
					nCommandParams[paramWrIndex] <= dataIn;
					paramWrIndex <= paramWrIndex + 1'b1;
				end
				
			endcase
		end

	end
	if (readScheduled && !sd_busy) begin 
		readSectorStart<=1;
		readScheduled <= 0;
	
	end
	//dma part
		//if (dma_ack_falling) dma_req <= 1'b0;

	if (readSectorDone) begin
        intrStatus[1] <= 1'b1; // Command Complete
        dma_start <= 1'b1;
        readScheduled <= 1'b0;
    end /*
        if (readSectorsRemaining > 1) begin
            readSectorsRemaining <= readSectorsRemaining - 1'b1;
            readSectorLba <= readSectorLba + 1'b1;
            sectorOffset         <= sectorOffset + 512;
            readScheduled <= 1'b1;
        end else begin
            readSectorsRemaining <= 0;
            intrStatus[1] <= 1'b1; // Command Complete
            dma_start <= 1'b1;
            readScheduled <= 1'b0;
        end
    end*/
    if (dma_busy_sync) dma_start <= 1'b0;
   // if (dma_transfer_done_sync)
     //   dma_start <= 1'b0;
	
	
end
//wire [31:0] dmaByteCount;



Gowin_SDPB disk_buffer(
        .dout(dmaDataOut), //output [31:0] dout
        .clka(clk), //input clka
        .cea(sdWr), //input cea
        .reseta(0), //input reseta
        .clkb(~dma_clk), //input clkb
        .ceb(1), //input ceb
        .resetb(0), //input resetb
        .oce(1), //input oce
        .ada(bramWriteAddr), //input [14:0] ada
        .din(sdDataIn), //input [7:0] din
        .adb(dmaByteCount) //input [12:0] adb
    );


//assign dmaDataOut = {8'haa,dmaByteCount[7:0],dmaByteCount[7:0],8'h55};


reg ack_sampled;
always @(negedge dma_clk) ack_sampled <= dma_ack;
reg cs_meta;
reg cs_sync;
reg cs_armed = 1'b1;
wire cs_fall;


wire resetCondition = (cs_fall & rd_raw);


typedef logic [3:0] dma_state_t;
wire start_sync;
syncEdgeDetect dma_start_sync(
    .clk(dma_clk),
    .signal(dma_start),
    .sync(start_sync)

);

wire ack_sync_dma;
syncEdgeDetect dma_ack_sync(
    .clk(dma_clk),
    .signal(dma_ack),
    .sync(ack_sync_dma)

);

localparam dma_state_t DMA_IDLE          = 8'h00;
localparam dma_state_t DMA_WAIT        = 8'h01;
localparam dma_state_t DMA_TRANSFER     = 8'h02;
dma_state_t currentDmaState = DMA_IDLE;

wire dma_busy = currentDmaState != DMA_IDLE;
always @(posedge dma_clk) begin
    case(currentDmaState)
        DMA_IDLE: begin 
            if(start_sync) begin 
                dma_req <= 1'b1;
                currentDmaState <= DMA_WAIT;
            end
        end
        DMA_WAIT: begin 
            dma_req <= 1'b1;
            if(ack_sync_dma) begin 
                dma_req <= 1'b0;
                currentDmaState <= DMA_TRANSFER;
            end
        end
        DMA_TRANSFER: begin 
            if(!dma_ack) begin 
                currentDmaState <= DMA_IDLE;
                dma_req <= 1'b0;
            end
        end
        default: currentDmaState <= DMA_IDLE;


    endcase
  
end
/*
always_comb begin 
    dmaDataOut <= {8'haa,dmaByteCount[7:0],dmaByteCount[7:0],8'h55};

end
*/
endmodule