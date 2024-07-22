module clint(
input clk,
input rst_n,
input [31:0] interrupt_flag_i,
input [31:0] inst_i,
input [31:0] inst_addr_i,
input jump_flag_i,
input [31:0] jump_addr_i,
input [2:0] hold_flag_i,
input [31:0] data_i,
input [31:0] csr_mtvec,
input [31:0] csr_mepc,
input [31:0] csr_mstatus,
input global_interrupt_en_i,
output hold_flag_o,
output reg csr_wr_en_o,
output reg [31:0] csr_wr_addr_o,
output reg [31:0] csr_rd_addr_o,
output reg [31:0] data_o,
output reg [31:0] interrupt_addr_o,
output reg interrupt_assert_o
);

localparam s_interrupt_idle = 4'b0001;
localparam s_interrupt_sync_assert = 4'b0010;
localparam s_interrupt_async_assert = 4'b0100;
localparam s_interrupt_mret = 4'b1000;

localparam s_csr_idle = 5'b00001;
localparam s_csr_mstatus = 5'b00010;
localparam s_csr_mepc = 5'b00100;
localparam s_csr_mstatus_mret = 5'b01000;
localparam s_csr_mcause = 5'b10000;

reg [3:0] interrupt_state;
reg [4:0] csr_state;
reg [31:0] inst_addr;
reg [31:0] cause;

assign hold_flag_o = ((interrupt_state != s_interrupt_idle) | (csr_state != s_csr_idle))? 1 : 0;

always@(*)begin
	if(!rst_n) begin
		interrupt_state = s_interrupt_idle;
	end else begin
		if(inst_i == 32'h00000073 || inst_i == 32'h00100073) begin //ECALL,EBREAK
			interrupt_state = s_interrupt_sync_assert;
		end else if (interrupt_flag_i != 0 && global_interrupt_en_i == 1) begin
			interrupt_state = s_interrupt_async_assert;
		end else if (inst_i == 32'h30200073) begin //MRET
			interrupt_state = s_interrupt_mret;
		end else begin
			interrupt_state = s_interrupt_idle;
		end
	end
end
endmodule