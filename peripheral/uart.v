module uart(
input clk,
input rst_n,
input wr_en_i,
input [31:0] addr_i,
input [31:0] data_i,
output reg [31:0] data_o,
output reg tx_pin,
input rx_pin
);//baud rate = 115200, 8N1, when idle signal = 1

localparam div = 31'd434; // 50MHz/115200 = 434

reg [31:0] uart_ctrl; // [0]: tx enable  [1] rx enable
reg [31:0] uart_status; // [0] tx busy(read only) [1] rx over
reg [31:0] uart_div; //clk
reg [31:0] uart_rx; //rx data

reg tx_data_valid;
reg [7:0] tx_data;
reg [7:0] rx_data;
reg tx_data_ready;
reg rx_over;
reg [15:0] cycle;
reg [3:0] bit_cnt;
reg [2:0] state;
reg rx_q0;
reg rx_q1;
wire rx_negedge;
reg rx_start;
reg [3:0] rx_clk_edge_cnt;
reg [15:0] rx_div_cnt;
reg [15:0] rx_clk_cnt;
reg rx_clk_edge_level;

localparam UART_CTRL = 8'h0;
localparam UART_STATUS = 8'h4;
localparam UART_DIV = 8'h8;
localparam UART_TXDATA = 8'hc;
localparam UART_RXDATA = 8'h10;
localparam S_IDLE = 3'b001;
localparam S_SEND_BYTE = 3'b010;
localparam S_STOP = 3'b100;

always@(posedge clk) begin
	if (rst_n == 1'b0) begin
		uart_ctrl <= 32'b0;
		uart_status <= 32'b0;
		uart_rx <= 32'b0;
		uart_div <= div;
		tx_data_valid <= 1'b0;
	end else begin
		if (wr_en_i == 1'b1) begin
			case(addr_i[7:0])
				UART_CTRL:begin
					uart_ctrl <= data_i;
				end
				UART_DIV:begin
					uart_div <= data_i;
				end
				UART_STATUS:begin
					uart_status[1] <= data_i[1];
				end
				UART_TXDATA:begin
					if(uart_ctrl[0] == 1'b1 && uart_status[0] == 1'b0) begin
						tx_data <= data_i[7:0];
						uart_status[0] <= 1'b1;
						tx_data_valid <= 1'b1;
					end
				end
			endcase
		end else begin
			tx_data_valid <= 1'b0;
			if(tx_data_ready == 1'b1) begin
				uart_status[0] <= 1'b0;
			end
			if(uart_ctrl[1] == 1'b1) begin
				if(rx_over == 1'b1) begin
					uart_status[1] <= 1'b1;
					uart_rx <= {24'b0, rx_data};
				end
			end
		end
	end
end

always@(*) begin
	if(rst_n == 1'b0) begin
		data_o = 32'b0;
	end else begin
		case(addr_i[7:0])
			UART_CTRL:begin
				data_o = uart_ctrl;
			end
			UART_STATUS: begin
            data_o = uart_status;
         end
         UART_DIV: begin
            data_o = uart_div;
         end
         UART_RXDATA: begin
            data_o = uart_rx;
         end
         default: begin
            data_o = 32'b0;
			end
		endcase
	end
end

always@(posedge clk) begin
	if (rst_n == 1'b0) begin
		state <= S_IDLE;
		cycle <= 16'b0;
		tx_pin <= 1'b0;
		bit_cnt <= 4'b0;
		tx_data_ready <= 1'b0;
	end else begin
		if(state == S_IDLE) begin
			tx_pin <= 1'b1; // in IDLE, keep high
			tx_data_ready <= 1'b0;
			if (tx_data_valid == 1'b1) begin
				state <= S_SEND_BYTE;
				cycle <= 16'b0;
				bit_cnt <= 4'b0;
				tx_pin <= 1'b0; // start bit
			end
		end else begin
			cycle <= cycle + 1'b1;
			if (cycle == uart_div[15:0]) begin
				cycle <= 0;
				case (state)
					S_SEND_BYTE: begin
						bit_cnt <= bit_cnt + 1;
						if (bit_cnt == 4'd8) begin
							tx_pin <= 1'b1; //end bit
							state <= S_STOP;
						end else begin
							tx_pin <= tx_data[bit_cnt];
						end
					end
					S_STOP: begin
						tx_pin <= 1'b1;
						state <= S_IDLE;
						tx_data_ready <= 1'b1;
					end
				endcase
		end	
		end
	end
end

assign rx_negedge = rx_q1 && ~rx_q0;
always@(posedge clk) begin
	if(rst_n == 1'b0) begin
		rx_q1 <= 1'b0;
		rx_q0 <= 1'b0;
	end else begin
		rx_q0 <= rx_pin;
		rx_q1 <= rx_q0;
	end
end

always@(posedge clk) begin
	if (rst_n == 1'b0) begin
		rx_start <= 1'b0;
	end else begin
		if (uart_ctrl[1]) begin
			if (rx_negedge == 1) begin
				rx_start <= 1'b1;
			end else if (rx_clk_edge_cnt == 4'd9) begin
				rx_start <= 1'b0;
			end
		end else begin
			rx_start <= 1'b0;
		end
	end
end

always@(posedge clk) begin
	if(rst_n == 1'b0) begin
		rx_div_cnt <= 16'b0;
	end else begin
		if (rx_start == 1'b1 && rx_clk_edge_cnt == 4'b0) begin
			rx_div_cnt <= rx_div_cnt[15:0] >> 1; //ensure the data is captured in the middle, more stable
		end else begin
			rx_div_cnt <= rx_div_cnt[15:0];
		end
	end
end

always@(posedge clk) begin
	if (rst_n == 1'b0) begin
		rx_clk_cnt <= 16'b0;
	end else if (rx_start == 1'b1) begin
		if (rx_clk_cnt == rx_div_cnt) begin
			rx_clk_cnt <= 16'b0;
		end else begin
			rx_clk_cnt <= rx_clk_cnt + 1'b1;
		end
	end else begin
		rx_clk_cnt <= 16'b0;
	end
end

always@(posedge clk) begin
	if (rst_n == 1'b0) begin
		rx_clk_edge_cnt <= 4'b0;
		rx_clk_edge_level <= 1'b0;
	end else if (rx_start == 1'b1) begin
		if (rx_clk_cnt == rx_div_cnt) begin
			if(rx_clk_edge_cnt == 4'd9) begin
				rx_clk_edge_cnt <= 4'b0;
				rx_clk_edge_level <= 1'b0;
			end else begin
				rx_clk_edge_cnt <= rx_clk_edge_cnt + 1'b1;
				rx_clk_edge_level <= 1'b1;
			end
		end else begin
			rx_clk_edge_level <= 1'b0;
		end
	end else begin
		rx_clk_edge_cnt <= 4'b0;
		rx_clk_edge_level <= 1'b0;
	end
end

always@(posedge clk) begin
	if(rst_n == 1'b0) begin
		rx_data <= 8'b0;
		rx_over <= 1'b0;
	end else begin
		if (rx_start == 1'b1) begin
			if (rx_clk_edge_level == 1'b1) begin
				case (rx_clk_edge_cnt)
					1:begin // start bit
					end
					2,3,4,5,6,7,8,9:begin
						rx_data <= rx_data | (rx_pin << (rx_clk_edge_cnt - 2));
						if (rx_clk_edge_cnt == 4'd9) begin
							rx_over <= 1'b1;
						end
					end
					default:begin
					end
				endcase
			end
		end else begin
			rx_data <= 8'b0;
			rx_over <= 1'b0;
		end
	end
end
endmodule