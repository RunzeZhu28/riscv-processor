module core(
input clk,
input rst_n,
output [31:0] perip_addr_o,
input [31:0] perip_data_i,
output [31:0] perip_data_o,
output perip_req_o,
output perip_wr_en_o,
output [31:0] inst_addr_o,
input [31:0] inst_data_i,
input [4:0] jtag_reg_addr_i,
input [31:0] jtag_reg_data_i,
input jtag_reg_wr_en_i,
output [31:0] jtag_reg_data_o,
input rib_hold_flag_i,
input jtag_halt_flag_i,
input jtag_reset_flag_i,
input [7:0] interrupt_i
);

wire [31:0] pc_o;
wire ctrl_jump_flag_o;
wire [31:0] ctrl_jump_addr_o;
wire [2:0] ctrl_hold_flag_o;
wire ex_jump_flag_o;
wire [31:0] ex_jump_addr_o;
wire ex_hold_flag_o;
wire clint_hold_flag_o;
wire ex_reg_wr_en_o;
wire [4:0] ex_reg_wr_addr_o;
wire [31:0] ex_reg_wr_data_o;
wire [4:0] decode_reg1_addr_o;
wire [4:0] decode_reg2_addr_o;
wire [31:0] decode_reg1_data_i;
wire [31:0] decode_reg2_data_i;
wire ex_csr_wr_en_o;
wire [31:0] ex_csr_wr_addr_o;
wire [31:0] decocde_csr_rd_addr_o;
wire [31:0] ex_csr_data_o;
wire clint_csr_wr_en_o;
wire [31:0] clint_csr_wr_addr_o;
wire [31:0] clint_csr_rd_addr_o;
wire [31:0] clint_data_o;
wire [31:0] global_interrupt_en_o;
wire [31:0] csr_clint_data_o;
wire [31:0] clint_csr_mtvec;
wire [31:0] clint_csr_mepc;
wire [31:0] clint_csr_mstatus;
wire [31:0] csr_ex_data_o;
wire fetch_interrupt_flag_o;
wire [31:0] fetch_inst_o;
wire [31:0] fetch_addr_o;
wire [31:0] decode_op1_o;
wire [31:0] decode_op1_jump_o;
wire [31:0] decode_op2_o;
wire [31:0] decode_op2_jump_o;
wire [31:0] decode_inst_o;
wire [31:0] decode_inst_addr_o;
wire [31:0] decode_reg1_data_o;
wire [31:0] decode_reg2_data_o;
wire decode_reg_wr_en_o;
wire [4:0] decode_reg_wr_addr_o;
wire decode_csr_wr_en_o;
wire [31:0] decode_csr_data_o;
wire [31:0] decode_csr_wr_addr_o;
wire [31:0] dte_op1_o;
wire [31:0] dte_op1_jump_o;
wire [31:0] dte_op2_o;
wire [31:0] dte_op2_jump_o;
wire [31:0] dte_inst_o;
wire [31:0] dte_inst_addr_o;
wire [31:0] dte_reg1_data_o;
wire [31:0] dte_reg2_data_o;
wire dte_reg_wr_en_o;
wire [4:0] dte_reg_wr_addr_o;
wire dte_csr_wr_en_o;
wire [31:0] dte_csr_data_o;
wire [31:0] dte_csr_wr_addr_o; 
wire ex_mem_wr_en_o;
wire [31:0] ex_mem_wr_addr_o;
wire [31:0] ex_mem_rd_addr_o;
wire [31:0] ex_mem_wr_data_o;
wire ex_mem_req_o;
wire clint_interrupt_flag_o;
wire [31:0] clint_interrupt_addr_o;
assign inst_addr_o = pc_o;
assign perip_addr_o = (ex_mem_wr_en_o == 1)? ex_mem_wr_addr_o : ex_mem_rd_addr_o;
assign perip_data_o = ex_mem_wr_data_o;
assign perip_req_o = ex_mem_req_o;
assign perip_wr_en_o = ex_mem_wr_en_o;
program_counter program_counter_inst(
.clk(clk),
.rst_n(rst_n),
.jump_en_i(ctrl_jump_flag_o),
.jump_addr_i(ctrl_jump_addr_o),
.hold_en_i(ctrl_hold_flag_o),
.jtag_rst_i(jtag_reset_flag_i),
.pc_o(pc_o)
);

control control_inst(
.jump_flag_i(ex_jump_flag_o),
.jump_addr_i(ex_jump_addr_o),
.hold_flag_ex_i(ex_hold_flag_o),
.hold_flag_rib_i(rib_hold_flag_i),
.halt_flag_jtag_i(jtag_halt_flag_i),
.hold_flag_clint_i(clint_hold_flag_o),
.hold_flag_o(ctrl_hold_flag_o),
.jump_flag_o(ctrl_jump_flag_o),
.jump_addr_o(ctrl_jump_addr_o)
);


register register_inst(
.clk(clk),
.rst_n(rst_n),
.wr_en_i(ex_reg_wr_en_o),
.wr_add_i(ex_reg_wr_addr_o),
.wr_data_i(ex_reg_wr_data_o),
.jtag_en_i(jtag_reg_wr_en_o),
.jtag_add_i(jtag_reg_addr_i),
.jtag_data_i(jtag_data_i),
.r_add1_i(decode_reg1_addr_o),
.r_add2_i(decode_reg2_addr_o),
.r_data1_o(decode_reg1_data_i),
.r_data2_o(decode_reg2_data_i),
.jtag_data_o(jtag_reg_data_o)
);


csr_reg csr_reg_inst(
.clk(clk),
.rst_n(rst_n),
.ex_wr_en_i(ex_csr_wr_en_o),
.ex_rd_addr_i(decode_csr_rd_addr_o),
.ex_wr_addr_i(ex_csr_wr_addr_o),
.ex_data_i(ex_csr_data_o),
.clint_wr_en_i(clint_csr_wr_en_o),
.clint_rd_addr_i(clint_csr_rd_addr_o),
.clint_wr_addr_i(clint_csr_wr_addr_o),
.clint_data_i(clint_data_o),
.global_interrupt_en_o(global_interrupt_en_o),
.clint_data_o(csr_clint_data_o),
.clint_csr_mtvec(clint_csr_mtvec),
.clint_csr_mepc(clint_csr_mepc),
.clint_csr_mstatus(clint_csr_mstatus),
.ex_data_o(csr_ex_data_o)
);


fetch fetch_inst(
.clk(clk),
.rst_n(rst_n),
.inst_i(inst_data_i),  
.inst_addr_i(pc_o),  
.hold_flag_i(ctrl_hold_flag_o),  
.interrupt_flag_i(interrupt_flag_i),
.interrupt_flag_o(fetch_interrupt_flag_o),
.inst_o(fetch_inst_o),
.inst_addr_o(fetch_addr_o)
);


decode decode_inst(
.rst_n(rst_n),
.inst_i(fetch_inst_o),
.inst_addr_i(fetch_addr_o),
.reg1_data_i(decode_reg1_data_i),
.reg2_data_i(decode_reg1_data_i), 
.csr_data_i(csr_ex_data_o),
.reg1_addr_o(decode_reg1_addr_o),
.reg2_addr_o(decode_reg2_addr_o),
.csr_rd_addr_o(decode_csr_rd_addr_o),
.op1_o(decode_op1_o),
.op2_o(decode_op2_o),
.op1_jump_o(decode_op1_jump_o),
.op2_jump_o(decode_op2_jump_o), 
.inst_o(decode_inst_o),
.inst_addr_o(decode_inst_addr_o),
.reg1_data_o(decode_reg1_data_o),
.reg2_data_o(decode_reg2_data_o),
.reg_wr_en_o(decode_reg_wr_en_o),
.reg_wr_addr_o(decode_reg_wr_addr_o),
.csr_wr_en_o(decode_csr_wr_en_o),
.csr_data_o(decode_csr_data_o),
.csr_wr_addr_o(decode_csr_wr_addr_o)
);


DecodeToExecute DecodeToExecute_inst(
.clk(clk),
.rst_n(rst_n),
.op1_i(decode_op1_o),
.op2_i(decode_op2_o),
.op1_jump_i(decode_op1_jump_o),
.op2_jump_i(decode_op2_jump_o), 
.inst_i(decode_inst_o),
.inst_addr_i(decode_inst_addr_o),
.reg1_data_i(decode_reg1_data_o),
.reg2_data_i(decode_reg2_data_o),
.reg_wr_en_i(decode_reg_wr_en_o),
.reg_wr_addr_i(decode_reg_wr_en_o),
.csr_wr_en_i(decode_csr_wr_en_o),
.csr_data_i(decode_csr_data_o),
.csr_wr_addr_i(decode_csr_wr_addr_o),
.hold_flag_i(ctrl_hold_flag_o),
.op1_o(dte_op1_o),
.op2_o(dte_op2_o),
.op1_jump_o(dte_op1_jump_o),
.op2_jump_o(dte_op2_jump_o), 
.inst_o(dte_inst_o),
.inst_addr_o(dte_inst_addr_o),
.reg1_data_o(dte_reg1_data_o),
.reg2_data_o(dte_reg2_data_o),
.reg_wr_en_o(dte_reg_wr_en_o),
.reg_wr_addr_o(dte_reg_wr_addr_o),
.csr_wr_en_o(dte_csr_wr_en_o),
.csr_data_o(dte_csr_data_o),
.csr_wr_addr_o(dte_csr_wr_addr_o)
);


execution execution_inst(
.op1_i(dte_op1_o),
.op2_i(dte_op2_o),
.op1_jump_i(dte_op1_jump_o),
.op2_jump_i(dte_op2_jump_o), 
.inst_i(dte_inst_o),
.inst_addr_i(dte_inst_addr_o),
.reg1_data_i(dte_reg1_data_o),
.reg2_data_i(dte_reg2_data_o),
.reg_wr_en_i(dte_reg_wr_en_o),
.reg_wr_addr_i(dte_reg_wr_addr_o),
.csr_wr_en_i(dte_csr_wr_en_o),
.csr_data_i(dte_csr_data_o),
.csr_wr_addr_i(dte_csr_wr_addr_o),
.interrupt_i(clint_interrupt_flag_o),
.interrupt_addr_i(clint_interrupt_addr_o),
.mem_data_i(perip_data_i),
.mem_data_o(ex_mem_wr_data_o),
.mem_rd_addr_o(ex_mem_rd_addr_o),
.mem_wr_addr_o(ex_mem_wr_addr_o),
.mem_wr_en_o(ex_mem_wr_en_o),
.mem_req_o(ex_mem_req_o),
.reg_data_o(ex_reg_data_o),
.reg_wr_en_o(ex_reg_wr_en_o),
.reg_wr_addr_o(ex_reg_wr_addr_o),
.csr_data_o(ex_csr_data_o),
.csr_wr_en_o(ex_csr_wr_en_o),
.csr_wr_addr_o(ex_csr_wr_addr_o),
.hold_flag_o(ex_hold_flag_o),
.jump_flag_o(ex_jump_flag_o),
.jump_addr_o(ex_jump_addr_o)
);
clint clint_inst(
.clk(clk),
.rst_n(rst_n),
.interrupt_flag_i(fetch_interrupt_flag_o),
.inst_i(ferch_inst_o),
.inst_addr_i(fetch_inst_addr_o),
.jump_flag_i(ex_jump_flag_o),
.jump_addr_i(ex_jump_addr_o),
.hold_flag_i(ctrl_hold_flag_o),
.data_i(csr_clint_data_o),
.csr_mtvec(clint_mtvec),
.csr_mepc(clint_mepc),
.csr_mstatus(csr_mstatus),
.global_interrupt_en_i(csr_global_interrupt_en_o),
.hold_flag_o(clint_hold_flag_o),
.csr_wr_en_o(clint_csr_wr_en_o),
.csr_wr_addr_o(clint_csr_wr_addr_o),
.csr_rd_addr_o(clint_csr_rd_addr_o),
.data_o(clint_data_o),
.interrupt_addr_o(clint_interrupt_addr_o),
.interrupt_assert_o(clint_interrupt_flag_o)
);
endmodule