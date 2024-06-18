module register(
	input clk,
	input rst,
	input wr_en_i,
	input [4:0] wr_add_i,
	input [31:0] wr_data_i,
	input jtag_en_i,
	input [4:0] jtag_add_i,
	input [31:0] jtag_data_i,
	input [4:0] r_add1_i,
	input [4:0] r_add2_i,
	output [31:0] r_data1_o,
	output [31:0] r_data2_o,
	output [31:0] jtag_data_o
);


endmodule