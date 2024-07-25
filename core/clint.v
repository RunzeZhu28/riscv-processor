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

always@(posedge clk)begin
	if(rst_n == 0) begin
		csr_state <= s_csr_idle;
		cause <= 0;
		inst_addr <= 0;
	end else begin
		case(csr_state)
			s_csr_idle:begin
				if(interrupt_state == s_interrupt_sync_assert) begin
					csr_state <= s_csr_mepc;
					if(jump_flag_i == 1) begin
						inst_addr <= jump_addr_i - 4;
					end else begin
						inst_addr <= inst_addr_i;
					end
					case(inst_i)
						32'h00000073:begin //ECALL
							cause <= 32'd11;
						end
						32'h00100073:begin //EBREAK
							cause <= 32'd3;
						end
						default:begin
							cause <= 32'd10;
						end
					endcase
				end else if (interrupt_state == s_interrupt_async_assert)begin
					cause <= 32'h80000004; //timer
					csr_state <= s_csr_mepc;
					if (jump_flag_i == 1)begin
						inst_addr <= jump_addr_i;
					end else begin
						inst_addr <= inst_addr_i;
					end
				end else if (interrupt_state == s_interrupt_mret) begin
					csr_state <= s_csr_mstatus_mret;
				end
			end
			s_csr_mepc: begin
				csr_state <= s_csr_mstatus;
			end
			s_csr_mstatus: begin
				csr_state <= s_csr_mcause;
			end
			s_csr_mstatus_mret:begin
				csr_state <= s_csr_idle;
			end
			default: begin
				csr_state <= s_csr_idle;
			end
		endcase
	end
end

always@(posedge clk)begin
	if(rst_n == 0) begin
		csr_wr_en_o <= 0;
		csr_wr_addr_o <= 0;
		data_o <= 0;
	end else begin
		case(csr_state)
			s_csr_mepc: begin
				csr_wr_en_o <= 1;
				csr_wr_addr_o <= {20'h0,12'h341};   //csr_mepc
				data_o <= inst_addr;
			end
			s_csr_mcause: begin
				csr_wr_en_o <= 1;
				csr_wr_addr_o <= {20'h0,12'h342};   //csr_mcause
				data_o <= cause;
			end
			s_csr_mstatus:begin
				csr_wr_en_o <= 1;
				csr_wr_addr_o <= {20'h0,12'h300};   //csr_mstatus
				data_o <= {csr_mstatus[31:8],csr_mstatus[3],csr_mstatus[6:4], 1'b0, csr_mstatus[2:0]};//MPIE = MIE,MIE = 0, pause other interrupt
			end
			s_csr_mstatus_mret: begin
				csr_wr_en_o <= 1;
				csr_wr_addr_o <= {20'h0,12'h300};   //csr_mstatus
				data_o <= {csr_mstatus[31:8], 1'b1, csr_mstatus[6:4], csr_mstatus[7],csr_mstatus[2:0]};
			end
			default: begin
				csr_wr_en_o <= 0;
				csr_wr_addr_o <= 0;
				data_o <= 0;
			end
		endcase
	end
end

always@(posedge clk)begin
	if(rst_n == 0) begin
		interrupt_assert_o <= 0;
		interrupt_addr_o <= 0;
	end else begin
		case (csr_state)
			s_csr_mcause:begin
				interrupt_assert_o <= 1;
				interrupt_addr_o <= csr_mtvec;
			end
			s_csr_mstatus_mret:begin
				interrupt_assert_o <= 1;
				interrupt_addr_o <= csr_mepc;
			end
			default:begin
				interrupt_assert_o <= 0;
				interrupt_addr_o <= 0;
			end
		endcase
	end
end
endmodule