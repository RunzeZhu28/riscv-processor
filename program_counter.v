module program_counter(
	input clk,
	input rst,
	input jump_en_i,
	input [31:0] jump_addr_i,
	input [2:0]  hold_en_i,
	input jtag_rst_i,
	output reg [31:0] pc_o	
);

always@(posedge clk) 
begin
	if (rst || jtag_rst_i)
	begin
		pc_o <= 0;
	end
	
	else if (jump_en_i)
	begin
		pc_o <= jump_addr_i;
	end
	
	else if (hold_en_i)
	begin
		pc_o <= pc_o;
	end
	
	else
	begin
		pc_o <= pc_o + 4;
	end
end

endmodule