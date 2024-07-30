module timer(
input clk,
input rst_n,
input [31:0] data_i,
input [31:0] addr_i,
input wr_en_i,
output reg [31:0] data_o,
output interrupt_o
);

localparam CTRL = 4'b0;
localparam COUNT = 4'h4;
localparam VALUE = 4'h8;

reg [31:0] timer_ctrl; // [0] enable, [1] interrupt enable  [2] interrupt pending, write 1 to clear
reg [31:0] timer_counter;//counter
reg [31:0] timer_value;//time to be counted

assign interrupt_o = ((timer_ctrl[2] == 1'b1) && (timer_ctrl[1] == 1'b1)) ? 1'b1 : 1'b0;

always@(posedge clk) begin
	if (rst_n == 1'b0) begin
		timer_counter <= 0;
	end else if (timer_ctrl[0] == 1'b1) begin
		if (timer_counter >= timer_value) begin
			timer_counter <= 0;
		end
		else begin
			timer_counter <= timer_counter + 1'b1;
		end
	end
end

always@(posedge clk) begin
	if (rst_n == 1'b0) begin
		timer_ctrl <= 0;
		timer_value <= 0;
	end else begin
		if (wr_en_i == 1) begin
			case(addr_i)
				CTRL: begin
					timer_ctrl <= {data_i[31:3], (timer_ctrl[2] & (~data_i[2])), data_i[1:0]};
				end
				VALUE:begin
					timer_ctrl <= data_i;
				end
			endcase
		end else begin
			if ((timer_ctrl[0] == 1'b1) && (timer_counter >= timer_value)) begin
				timer_ctrl[0] <= 1'b0;
				timer_ctrl[2] <= 1'b1;
			end
		end
	end
end

always@(*) begin
	if(rst_n == 1'b0) begin
		data_o = 0;
	end else begin
		case(addr_i)
			CTRL: begin
				data_o = timer_ctrl;
			end
			COUNT: begin
				data_o = timer_counter;
			end
			VALUE: begin
				data_o = timer_value;
			end
			default: begin
				data_o = 0;
			end
		endcase
	end
end
endmodule