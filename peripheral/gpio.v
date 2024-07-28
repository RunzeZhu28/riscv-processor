module gpio(
input clk,
input rst_n,
input wr_en_i,
input [31:0] addr_i,
input [31:0] data_i,
output reg [31:0] data_o,
input [1:0] io_pin_i,
output [31:0] reg_ctrl,
output [31:0] reg_data
);
localparam CTRL = 4'h0;
localparam DATA = 4'h4;
reg [31:0] gpio_ctrl; // 2 bit control 1 IO mode: 0: Z  1: input 2: output
reg [31:0] gpio_data;

assign reg_ctrl = gpio_ctrl;
assign reg_data = gpio_data;
always@(posedge clk) begin
	if(rst_n == 1'b0) begin
		gpio_ctrl <= 0;
		gpio_data <= 0;
	end else if (wr_en_i == 1) begin
		case(addr_i[3:0]) 
			CTRL:begin
				gpio_ctrl <= data_i;
			end
			DATA: begin
				gpio_data <= data_i;
			end
		endcase
	end else begin
		if (gpio_ctrl[1:0] == 2'b10) begin
			gpio_data[0] <= io_pin_i[0];
		end
		if (gpio_ctrl[3:2] == 2'b10) begin
			gpio_data[1] <= io_pin_i[1];
		end
	end
end

always@(*) begin
	if(rst_n == 1'b0) begin
		data_o = 0;
	end else begin
		case(addr_i[3:0])
			CTRL:begin
				data_o = gpio_ctrl;
			end
			DATA:begin
				data_o = gpio_data;
			end
			default:begin
				data_o = 0;
			end
		endcase
	end
end
endmodule