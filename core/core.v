module core(
input clk,
input rst_n,
output [31:0] perip_addr_o,
input [31:0] perip_data_i,
output [31:0] perip_data_o,
output perip_req_o,
output perip_wr_en_o,
output [31:0] pc_addr_o,
input [31:0] pc_data_i,
input [31:0] jtag_reg_addr_i,
input [31:0] jtag_reg_data_i,
input jtag_reg_wr_en_i,
output [31:0] jtag_reg_data_o,
input hold_flag_i,
input jtag_halt_flag_i,
input jtag_reset_flag_i,
input [31:0] interrupt_i
);

wire [31:0] pc_o;
wire ctrl_jump_flag_o;
wire [31:0] ctrl_jump_addr_o;
wire [2:0] ctrl_hold_flag_o;
program_counter program_counter_inst(
.clk(clk),
.rst_n(rst_n),
.jump_en_i(ctrl_jump_flag_o),
.jump_addr_i(ctrl_jump_addr_o),
.hold_en_i(ctrl_hold_flag_o),
.jtag_rst_i(jtag_reset_flag_i),
.pc_o(pc_o)
);
endmodule