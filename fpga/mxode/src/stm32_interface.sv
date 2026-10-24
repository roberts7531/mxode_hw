module stm32_interface(
    input wire clk,


    input wire stm32_cs,
    input wire stm32_sck,
    input wire stm32_mosi,
    output logic stm32_miso,
    output logic stm32_irq,

    input wire spi_request,
    output logic spi_busy,
    output logic spi_ready,
    output logic spi_error,

    input wire [7:0] spiDataOut[0:19],
    input wire [4:0] spiTransferLen,
    output logic [7:0] spiDataIn[0:19]

);
    

reg [7:0] tx_shift;
reg [7:0] rx_shift;
reg [4:0] byte_count;
reg [2:0] bit_count;

reg [1:0] spi_state;

localparam SPI_IDLE = 2'd0;
localparam SPI_WAIT = 2'd1;
localparam SPI_XFER = 2'd2;
localparam SPI_DONE = 2'd3;

wire sck_sync;
wire sck_fall;
wire sck_rise;
syncEdgeDetect sckSync(
    .clk(clk),
    .signal(stm32_sck),
    .falling(sck_fall),
    .rising(sck_rise)

);

wire cs_sync;
syncEdgeDetect csSync(
    .clk(clk),
    .signal(stm32_cs),
    .sync(cs_sync)

);

wire mosi_sync;
syncEdgeDetect mosiSync(
    .clk(clk),
    .signal(stm32_mosi),
    .sync(mosi_sync)

);

reg tx_byte_start;
always @(posedge clk) begin 
	 spi_ready <= 0;
	 spi_busy <=1;
	 case(spi_state) 
			SPI_IDLE: begin 
                spi_busy<=0;
				stm32_irq <= 1;
				if (spi_request) begin
                    byte_count <= 0;
                    bit_count  <= 0;
                    tx_shift   <= spiDataOut[0];
                    rx_shift   <= 0;
					spi_error <= 0;
					tx_byte_start <= 1'b0;
                    spi_state  <= SPI_WAIT;
                    stm32_irq <= 1'b0;  // Notify STM32
                end
			end
			SPI_WAIT: begin 
				if (!cs_sync) begin
					stm32_irq <= 1'b1;
                    // First output bit must be valid before
                    // the first rising SCK edge.
                    stm32_miso <= tx_shift[7];
                    spi_state <= SPI_XFER;
                end
			end
			SPI_XFER: begin
            if (cs_sync) begin
                // STM32 ended the transaction unexpectedly.
                spi_state <= SPI_DONE;
            end
            else begin
                if (sck_fall) begin
					if (tx_byte_start) begin
						// First falling edge of a new byte:
						// present its MSB without shifting it away.
						stm32_miso <= tx_shift[7];
						tx_byte_start <= 1'b0;
					end else begin
						// Normal bit advance.
						tx_shift <= {tx_shift[6:0], 1'b0};
						stm32_miso <= tx_shift[6];
					end
				end

                if (sck_rise) begin
                    // Receive one bit, MSB first.
                    rx_shift <= {rx_shift[6:0], mosi_sync};

                    if (bit_count == 7) begin
						spiDataIn[byte_count] <= {rx_shift[6:0], mosi_sync};
						bit_count <= 0;

						if (byte_count == spiTransferLen - 1'b1) begin
							spi_state <= SPI_DONE;
						end else begin
							byte_count <= byte_count + 1'b1;
							tx_shift <= spiDataOut[byte_count + 1'b1];
							tx_byte_start <= 1'b1;
						end
					end else begin
						bit_count <= bit_count + 1'b1;
					end
				end
            end
        end

        SPI_DONE: begin
			spi_error <= (spiDataIn[spiTransferLen - 1'b1] != 8'hDE);
			spi_ready <= 1'b1;
			spi_state <= SPI_IDLE;
		end
	 endcase 
end
endmodule