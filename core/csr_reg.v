module csr_reg(
input clk,
input rst_n,
input ex_wr_en_i,
input [31:0] ex_rd_addr_i,
input [31:0] ex_wr_addr_i,
input [31:0] ex_data_i,
input clint_wr_en_i,
input [31:0] clint_rd_addr_i,
input [31:0] clint_wr_addr_i,
input [31:0] clint_data_i,
output [31:0] global_interrupt_en_o,
output reg [31:0] clint_data_o,
output [31:0] clint_csr_mtvec,
output [31:0] clint_csr_mepc,
output [31:0] clint_csr_mstatus,
output reg [31:0] ex_data_o
);

reg [63:0] cycle;
reg [31:0] mtvec;
reg [31:0] mcause;
reg [31:0] mepc;
reg [31:0] mie;
reg [31:0] mstatus;
reg [31:0] mscratch;

assign global_interrupt_en_o = (mstatus[3] == 1'b1) ? 1 : 0;
assign clint_csr_mtvec = mtvec;
assign clint_csr_mepc = mepc;
assign clint_csr_mstatus = mstatus;

always@(posedge clk) begin
	if(rst_n == 0) begin
		cycle <= 0;
	end else begin
		cycle <= cycle + 1'b1;
	end
end

always@(posedge clk) begin
	if (rst_n == 0) begin
		mtvec <= 0;
		mcause <= 0;
		mepc <= 0;
		mie <= 0;
		mstatus <= 0;
		mscratch <= 0;
	end else begin
		if(ex_wr_en_i == 1) begin
			case(ex_wr_addr_i[11:0])
				12'h305:begin 
					mtvec <= ex_data_i;
				end
				12'h342:begin 
					mcause <= ex_data_i;
				end
				12'h341:begin 
					mepc <= ex_data_i;
				end
				12'h304:begin 
					mie <= ex_data_i;
				end
				12'h300:begin 
					mstatus <= ex_data_i;
				end
				12'h340:begin 
					mscratch <= ex_data_i;
				end
				default:begin
				end
			endcase
		end else if (clint_wr_en_i == 1) begin
			case(clint_wr_addr_i[11:0])
				12'h305:begin 
					mtvec <= clint_data_i;
				end
				12'h342:begin 
					mcause <= clint_data_i;
				end
				12'h341:begin 
					mepc <= clint_data_i;
				end
				12'h304:begin 
					mie <= clint_data_i;
				end
				12'h300:begin 
					mstatus <= clint_data_i;
				end
				12'h340:begin 
					mscratch <= clint_data_i;
				end
				default:begin
				end
			endcase
		end
	end
end

always@(*) begin
	if ((ex_wr_addr_i[11:0] == ex_rd_addr_i[11:0]) && (ex_wr_en_i == 1)) begin
		ex_data_o = ex_data_i;
	end else begin
		case (ex_rd_addr_i[11:0])
			12'h305:begin 
				ex_data_o <= mtvec; 
			end
			12'h342:begin 
				ex_data_o <= mcause; 
			end
			12'h341:begin 
				ex_data_o <= mepc;
			end
			12'h304:begin 
				ex_data_o <= mie;
			end
			12'h300:begin 
				ex_data_o <= mstatus;
			end
			12'h340:begin 
				ex_data_o <= mscratch;
			end
			12'hc00:begin //CYCLE
				ex_data_o <= cycle[31:0];
			end
			12'hc80:begin //CYCLEH
				ex_data_o <= cycle[63:32];
			end
			default:begin
				ex_data_o <= 0;
			end
		endcase
	end
end

always@(*) begin
	if ((clint_wr_addr_i[11:0] == clint_rd_addr_i[11:0]) && (clint_wr_en_i == 1)) begin
		clint_data_o = clint_data_i;
	end else begin
		case (clint_rd_addr_i[11:0])
			12'h305:begin 
				clint_data_o <= mtvec; 
			end
			12'h342:begin 
				clint_data_o <= mcause; 
			end
			12'h341:begin 
				clint_data_o <= mepc;
			end
			12'h304:begin 
				clint_data_o <= mie;
			end
			12'h300:begin 
				clint_data_o <= mstatus;
			end
			12'h340:begin 
				clint_data_o <= mscratch;
			end
			12'hc00:begin //CYCLE
				clint_data_o <= cycle[31:0];
			end
			12'hc80:begin //CYCLEH
				clint_data_o <= cycle[63:32];
			end
			default:begin
				clint_data_o <= 0;
			end
		endcase
	end
end

endmodule