module control(
input jump_flag_i,
input [31:0] jump_addr_i,
input hold_flag_ex_i,
input hold_flag_rib_i,
input halt_flag_jtag_i,
input hold_flag_clint_i,
output [2:0] hold_flag_o,
output jump_flag_o,
output [31:0] jump_addr_o
);

always@(*) begin
	jump_addr_o = jump_addr_i;
	jump_flag_o = jump_flag_i;
	hold_flag = 0;
	if(jump_flag_i == 1 || hold_flag_ex_i == 1 || hold_flag_clint_i == 1) begin
		hold_flag_o = 3'b011; //pause the pipeline
	end else if (hold_flag_rib_i == 1) begin
		hold_flag_o = 3'b001; //pause pc
	end else if (halt_flag_jtag_i == 1) begin
		hold_flag_o = 3'b011;
	end else begin
		hold_flag_o = 0;
	end
end

endmodule