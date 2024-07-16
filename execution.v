module execution(
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
input interrupt_i,
input [31:0] interrupt_addr_i,
input [31:0] mem_data_i,
output reg [31:0] mem_data_o,
output reg [31:0] mem_rd_addr_o,
output reg [31:0] mem_wr_addr_o,
output mem_wr_en_o,
output mem_req_o,
output [31:0] reg_data_o,
output reg_wr_en_o,
output [31:0] reg_wr_addr_o,
output reg [31:0] csr_data_o,
output csr_wr_en_o,
output [31:0] csr_wr_addr_o,
output hold_flag_o,
output jump_flag_o,
output [31:0] ju,p_addr_o
);

 wire[6:0] opcode = inst_i[6:0];
 wire[2:0] funct3 = inst_i[14:12];
 wire[6:0] funct7 = inst_i[31:25];
 wire[4:0] rd = inst_i[11:7];
 wire[4:0] uimm = inst_i[19:15];
	 
endmodule