module rom(
input clk,
input rst_n,
input wr_en_i,
input [31:0] addr_i,
input [31:0] data_i,
output reg [31:0] data_o
); //store the program

reg [31:0] rom[0:4095];  // not enough for 32 bits

always@(posedge clk) begin
	if(wr_en_i == 1) begin
		rom[addr_i[31:2]] <= data_i;   //  only check words
	end
end  // only write program at the start

always@(*) begin
	if (rst_n == 0) begin
		data_o = 0;
	end else begin
		data_o = rom[addr_i[31:2]];
	end
end
endmodule