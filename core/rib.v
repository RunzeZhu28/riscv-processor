module rib(
input clk,
input rst_n,
input [31:0] m0_addr_i, //rib
input [31:0] m0_data_i,
output reg [31:0] m0_data_o,
input m0_req_i,
input m0_wr_en_i,

input [31:0] m1_addr_i, //pc
input [31:0] m1_data_i,
output reg [31:0] m1_data_o,
input m1_req_i,
input m1_wr_en_i,

input [31:0] m2_addr_i,  //jtag
input [31:0] m2_data_i,
output reg [31:0] m2_data_o,
input m2_req_i,
input m2_wr_en_i,

input [31:0] m3_addr_i,  //uart
input [31:0] m3_data_i,
output reg [31:0] m3_data_o,
input m3_req_i,
input m3_wr_en_i,

output reg [31:0] s0_addr_o, //ROM
output reg [31:0] s0_data_o,
input [31:0] s0_data_i,
output reg s0_wr_en_o,

output reg [31:0] s1_addr_o, //RAM
output reg [31:0] s1_data_o,
input [31:0] s1_data_i,
output reg s1_wr_en_o,

output reg [31:0] s2_addr_o, //timer
output reg [31:0] s2_data_o,
input [31:0] s2_data_i,
output reg s2_wr_en_o,

output reg [31:0] s3_addr_o, //uart
output reg [31:0] s3_data_o,
input [31:0] s3_data_i,
output reg s3_wr_en_o,

output reg [31:0] s4_addr_o, //gpio
output reg [31:0] s4_data_o,
input [31:0] s4_data_i,
output reg s4_wr_en_o,

output reg [31:0] s5_addr_o, //spi
output reg [31:0] s5_data_o,
input [31:0] s5_data_i,
output reg s5_wr_en_o,

output reg hold_flag_o
);

parameter [3:0] slave_0 = 4'b0000;
parameter [3:0] slave_1 = 4'b0001;
parameter [3:0] slave_2 = 4'b0010;
parameter [3:0] slave_3 = 4'b0011;
parameter [3:0] slave_4 = 4'b0100;
parameter [3:0] slave_5 = 4'b0101;

parameter [1:0] grant_0 = 2'b00;
parameter [1:0] grant_1 = 2'b01;
parameter [1:0] grant_2 = 2'b10;
parameter [1:0] grant_3 = 2'b11;
reg [1:0] grant;

always@(*) begin
	if(m3_req_i)begin
		grant = grant_3;
		hold_flag_o = 1;
	end else if(m0_req_i) begin
		grant = grant_0;
		hold_flag_o = 1;
	end else if(m2_req_i) begin
		grant = grant_2;
		hold_flag_o = 1;
	end else begin
		grant = grant_1;
		hold_flag_o = 0;
	end
end

always@(*) begin
	m0_data_o = 0;
	m1_data_o = 32'b10011;
	m2_data_o = 0;
	m3_data_o = 0;
	
	s0_addr_o = 0;
	s1_addr_o = 0;
	s2_addr_o = 0;
	s3_addr_o = 0;
	s4_addr_o = 0;
	s5_addr_o = 0;
	s0_data_o = 0;
	s1_data_o = 0;
	s2_data_o = 0;
	s3_data_o = 0;
	s4_data_o = 0;
	s5_data_o = 0;
	s0_wr_en_o = 0;
	s1_wr_en_o = 0;
	s2_wr_en_o = 0;
	s3_wr_en_o = 0;
	s4_wr_en_o = 0;
	s5_wr_en_o = 0;
	
	case(grant)
		grant_0:begin
			case(m0_addr_i[31:28]) //first four bits to check which slaver
				slave_0:begin
					s0_wr_en_o = m0_wr_en_i;
					s0_addr_o = {{4'b0},{m0_addr_i[27:0]}};
					s0_data_o = m0_data_i;
					m0_data_o = s0_data_i;
				end
				slave_1:begin
					s1_wr_en_o = m0_wr_en_i;
					s1_addr_o = {{4'b0},{m0_addr_i[27:0]}};
					s1_data_o = m0_data_i;
					m0_data_o = s1_data_i;
				end
				slave_2:begin
					s2_wr_en_o = m0_wr_en_i;
					s2_addr_o = {{4'b0},{m0_addr_i[27:0]}};
					s2_data_o = m0_data_i;
					m0_data_o = s2_data_i;
				end
				slave_3:begin
					s3_wr_en_o = m0_wr_en_i;
					s3_addr_o = {{4'b0},{m0_addr_i[27:0]}};
					s3_data_o = m0_data_i;
					m0_data_o = s3_data_i;
				end
				slave_4:begin
					s4_wr_en_o = m0_wr_en_i;
					s4_addr_o = {{4'b0},{m0_addr_i[27:0]}};
					s4_data_o = m0_data_i;
					m0_data_o = s4_data_i;
				end
				slave_5:begin
					s5_wr_en_o = m0_wr_en_i;
					s5_addr_o = {{4'b0},{m0_addr_i[27:0]}};
					s5_data_o = m0_data_i;
					m0_data_o = s5_data_i;
				end
				default:begin
				end
			endcase
		end
		grant_1:begin
			case(m1_addr_i[31:28]) 
				slave_0:begin
					s0_wr_en_o = m1_wr_en_i;
					s0_addr_o = {{4'b0},{m1_addr_i[27:0]}};
					s0_data_o = m1_data_i;
					m1_data_o = s0_data_i;
				end
				slave_1:begin
					s1_wr_en_o = m1_wr_en_i;
					s1_addr_o = {{4'b0},{m1_addr_i[27:0]}};
					s1_data_o = m1_data_i;
					m1_data_o = s1_data_i;
				end
				slave_2:begin
					s2_wr_en_o = m1_wr_en_i;
					s2_addr_o = {{4'b0},{m1_addr_i[27:0]}};
					s2_data_o = m1_data_i;
					m1_data_o = s2_data_i;
				end
				slave_3:begin
					s3_wr_en_o = m1_wr_en_i;
					s3_addr_o = {{4'b0},{m1_addr_i[27:0]}};
					s3_data_o = m1_data_i;
					m1_data_o = s3_data_i;
				end
				slave_4:begin
					s4_wr_en_o = m1_wr_en_i;
					s4_addr_o = {{4'b0},{m1_addr_i[27:0]}};
					s4_data_o = m1_data_i;
					m1_data_o = s4_data_i;
				end
				slave_5:begin
					s5_wr_en_o = m1_wr_en_i;
					s5_addr_o = {{4'b0},{m1_addr_i[27:0]}};
					s5_data_o = m1_data_i;
					m1_data_o = s5_data_i;
				end
				default:begin
				end
			endcase
		end
		grant_2:begin
			case(m2_addr_i[31:28]) 
				slave_0:begin
					s0_wr_en_o = m2_wr_en_i;
					s0_addr_o = {{4'b0},{m2_addr_i[27:0]}};
					s0_data_o = m2_data_i;
					m2_data_o = s0_data_i;
				end
				slave_1:begin
					s1_wr_en_o = m2_wr_en_i;
					s1_addr_o = {{4'b0},{m2_addr_i[27:0]}};
					s1_data_o = m2_data_i;
					m2_data_o = s1_data_i;
				end
				slave_2:begin
					s2_wr_en_o = m2_wr_en_i;
					s2_addr_o = {{4'b0},{m2_addr_i[27:0]}};
					s2_data_o = m2_data_i;
					m2_data_o = s2_data_i;
				end
				slave_3:begin
					s3_wr_en_o = m2_wr_en_i;
					s3_addr_o = {{4'b0},{m2_addr_i[27:0]}};
					s3_data_o = m2_data_i;
					m2_data_o = s3_data_i;
				end
				slave_4:begin
					s4_wr_en_o = m0_wr_en_i;
					s4_addr_o = {{4'b0},{m2_addr_i[27:0]}};
					s4_data_o = m2_data_i;
					m2_data_o = s4_data_i;
				end
				slave_5:begin
					s5_wr_en_o = m2_wr_en_i;
					s5_addr_o = {{4'b0},{m2_addr_i[27:0]}};
					s5_data_o = m2_data_i;
					m2_data_o = s5_data_i;
				end
				default:begin
				end
			endcase
		end
		grant_3:begin
			case(m3_addr_i[31:28]) 
				slave_0:begin
					s0_wr_en_o = m3_wr_en_i;
					s0_addr_o = {{4'b0},{m3_addr_i[27:0]}};
					s0_data_o = m3_data_i;
					m3_data_o = s0_data_i;
				end
				slave_1:begin
					s1_wr_en_o = m3_wr_en_i;
					s1_addr_o = {{4'b0},{m3_addr_i[27:0]}};
					s1_data_o = m3_data_i;
					m3_data_o = s1_data_i;
				end
				slave_2:begin
					s2_wr_en_o = m3_wr_en_i;
					s2_addr_o = {{4'b0},{m3_addr_i[27:0]}};
					s2_data_o = m3_data_i;
					m3_data_o = s2_data_i;
				end
				slave_3:begin
					s3_wr_en_o = m3_wr_en_i;
					s3_addr_o = {{4'b0},{m3_addr_i[27:0]}};
					s3_data_o = m3_data_i;
					m3_data_o = s3_data_i;
				end
				slave_4:begin
					s4_wr_en_o = m3_wr_en_i;
					s4_addr_o = {{4'b0},{m3_addr_i[27:0]}};
					s4_data_o = m3_data_i;
					m3_data_o = s4_data_i;
				end
				slave_5:begin
					s5_wr_en_o = m3_wr_en_i;
					s5_addr_o = {{4'b0},{m3_addr_i[27:0]}};
					s5_data_o = m3_data_i;
					m3_data_o = s5_data_i;
				end
				default:begin
				end
			endcase
		end
		
		default:begin
		end
	endcase
end
endmodule