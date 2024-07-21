module fetch(
input clk,
input rst_n,
input [31:0] inst_i,   // from last cycle
input [31:0] inst_addr_i,  //new instruction
input [2:0] hold_flag_i,  //pipeline hold
input [7:0] interrupt_flag_i,
output [7:0] interrupt_flag_o,
output [31:0] inst_o,
output [31:0] inst_addr_o
);

wire hold_en = (hold_flag_i >= 3'b010);  //only enable when the whole pipeline is paused

wire [31:0] inst;
gen_pipe_dff inst_gen_pipe_dff(clk, rst_n, hold_en, 32'b10011, inst_i, inst); //32'b10011 is NOP in risc-v
assign inst_o = inst;

wire [31:0] inst_addr;
gen_pipe_dff inst_gen_addr_dff(clk, rst_n, hold_en, 0, inst_addr_i, inst_addr);
assign inst_addr_o = inst_addr;

wire [7:0] interrupt_flag;
gen_pipe_dff inst_gen_interrupt_dff(clk, rst_n, hold_en, 0, interrupt_flag_i, interrupt_flag);
assign interrupt_flag_o = interrupt_flag;

endmodule
