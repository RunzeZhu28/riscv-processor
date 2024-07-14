module DecodeToExecute(
input clk,
input rst_n,
input [31:0] op1_i,
input [31:0] op2_i,
input [31:0] op1_jump_i,
input [31:0] op2_jump_i, 
input [31:0] inst_i,
input [31:0] inst_addr_i,
input [31:0] reg1_data_i,
input [31:0] reg2_data_i,
input reg_wr_en_i,
input [4:0] reg_wr_addr_i,
input csr_wr_en_i,
input [31:0] csr_rd_data_i,
input [31:0] csr_wr_addr_i,
input [2:0] hold_flag_i,

output [31:0] op1_o,
output [31:0] op2_o,
output [31:0] op1_jump_o,
output [31:0] op2_jump_o, 
output [31:0] inst_o,
output [31:0] inst_addr_o,
output [31:0] reg1_data_o,
output [31:0] reg2_data_o,
output reg_wr_en_o,
output [4:0] reg_wr_addr_o,
output csr_wr_en_o,
output [31:0] csr_rd_data_o,
output [31:0] csr_wr_addr_o
);

wire hold_en = (hold_flag_i >= 3'b010);  //only enable when the whole pipeline is paused

wire [31:0] op1;
gen_pipe_dff op1_dff(clk, rst_n, hold_en, 0, op1_i, op1); 
assign op1_o = op1;

wire [31:0] op2;
gen_pipe_dff op2_dff(clk, rst_n, hold_en, 0, op2_i, op2); 
assign op2_o = op2;

wire [31:0] op1_jump;
gen_pipe_dff op1_jump_dff(clk, rst_n, hold_en, 0, op1_jump_i, op1_jump); 
assign op1_jump_o = op1_jump;

wire [31:0] op2_jump;
gen_pipe_dff op2_jump_dff(clk, rst_n, hold_en, 0, op2_jump_i, op2_jump); 
assign op2_jump_o = op2_jump;

wire [31:0] inst;
gen_pipe_dff inst_dff(clk, rst_n, hold_en, 32'b10011, inst_i, inst); //32'b10011 is NOP in risc-v
assign inst_o = inst;

wire [31:0] inst_addr;
gen_pipe_dff inst_addr_dff(clk, rst_n, hold_en, 0, inst_addr_i, inst_addr);
assign inst_addr_o = inst_addr;

wire [31:0] reg1_data;
gen_pipe_dff reg1_data_dff(clk, rst_n, hold_en, 0, reg1_data_i, reg1_data);
assign reg1_data_o = reg1_data;

wire [31:0] reg2_data;
gen_pipe_dff reg2_data_dff(clk, rst_n, hold_en, 0, reg2_data_i, reg2_data);
assign reg2_data_o = reg2_data;

wire reg_wr_en;
gen_pipe_dff #(1) reg_wr_en_dff(clk, rst_n, hold_en, 0, reg_wr_en_i, reg_wr_en);
assign reg_wr_en_o = reg_wr_en;

wire [4:0] reg_wr_addr;
gen_pipe_dff #(5) reg_wr_addr_dff(clk, rst_n, hold_en, 0, reg_wr_addr_i, reg_wr_addr);
assign reg_wr_addr_o = reg_wr_addr;

wire csr_wr_en;
gen_pipe_dff #(1) csr_wr_en_dff(clk, rst_n, hold_en, 0, csr_wr_en_i, csr_wr_en);
assign csr_wr_en_o = csr_wr_en;

wire [31:0] csr_rd_data;
gen_pipe_dff csr_rd_data_dff(clk, rst_n, hold_en, 0, csr_rd_data_i,csr_rd_data);
assign csr_rd_data_o = csr_rd_data;

wire [31:0] csr_wr_addr;
gen_pipe_dff csr_wr_addr_dff(clk, rst_n, hold_en, 0, csr_wr_addr_i, csr_wr_addr);
assign csr_wr_addr_o = csr_wr_addr;

endmodule 