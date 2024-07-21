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
input [31:0] csr_data_i,
input [31:0] csr_wr_addr_i,
input interrupt_i,
input [31:0] interrupt_addr_i,
input [31:0] mem_data_i,
output reg [31:0] mem_data_o,
output reg [31:0] mem_rd_addr_o,
output reg [31:0] mem_wr_addr_o,
output mem_wr_en_o,
output mem_req_o,
output reg [31:0] reg_data_o,
output reg_wr_en_o,
output [31:0] reg_wr_addr_o,
output reg [31:0] csr_data_o,
output csr_wr_en_o,
output [31:0] csr_wr_addr_o,
output reg hold_flag_o,
output jump_flag_o,
output [31:0] jump_addr_o
);

wire [6:0] opcode;
wire [4:0] rd ;
wire [2:0] funct3;
wire [4:0] uimm;
wire [6:0] funct7;
wire [31:0] op1_op2_sum;
wire [31:0] op1_op2_jump_sum;
reg mem_req;
reg jump_flag;
reg [31:0] jump_addr;
reg mem_wr_en;
//reg reg_wr_en;
wire [31:0] comparison_signed;
wire [31:0] comparison_unsigned;
wire [31:0] reg_shift;
wire [31:0] shift_mask;
wire [31:0] reg_shift_2;
wire [31:0] shift_mask_2;
wire [1:0]  mem_rd_addr_index;
wire [1:0]  mem_wr_addr_index;
wire op1_eq_op2;

assign opcode = inst_i[6:0];
assign rd = inst_i[11:7];
assign funct3 = inst_i[14:12];
assign uimm = inst_i[19:15];
assign funct7 = inst_i[31:25];
assign op1_op2_sum = op1_i + op2_i;
assign op1_op2_jump_sum = op1_jump_i + op2_jump_i;
assign reg_wr_addr_o = reg_wr_addr_i;
assign mem_req_o = (interrupt_i == 1) ? 0 : mem_req;
assign mem_wr_en_o = (interrupt_i == 1) ? 0 : mem_wr_en;
assign reg_wr_en_o = (interrupt_i == 1) ? 0 : reg_wr_en_i;
assign reg_wr_addr_o = reg_wr_addr_i;
assign comparison_signed = {31'b0, $signed(op1_i) < $signed(op2_i)};
assign comparison_unsigned = {31'b0, op1_i < op2_i};
assign reg_shift = reg1_data_i >> inst_i[24:20];
assign shift_mask = 32'hffffffff >> inst_i[24:20];
assign reg_shift_2 = reg1_data_i >> reg2_data_i[4:0];
assign shift_mask = 32'hffffffff >> reg2_data_i[4:0];
assign mem_rd_addr_index = (reg1_data_i + {{20{inst_i[31]}}, inst_i[31:20]}) & 2'b11;
assign mem_wr_addr_index = (reg1_data_i + {{20{inst_i[31]}}, inst_i[31:25],inst_i[11:7]}) & 2'b11;
assign op1_eq_op2 = (op1_i == op2_i);
assign csr_wr_en_o = (interrupt_i == 1) ? 0 : csr_wr_en_i;
assign csr_wr_addr_o = csr_wr_addr_i;
assign jump_flag_o = jump_flag || ((interrupt_i == 1) ? 1: 0);
assign jump_addr_o = (interrupt_i == 1) ? interrupt_addr_i : jump_addr;

always@(*) begin
	mem_req = 1'b0;
	csr_data_o = 0;
	
	case(opcode)
		7'b0010011:begin  //I type
			case(funct3)
				3'b000:begin //ADDI
					hold_flag_o = 0;
					jump_flag = 0;
					jump_addr = 0;
					mem_data_o = 0;
					mem_rd_addr_o = 0;
					mem_wr_addr_o = 0;
					mem_wr_en = 0;
					reg_data_o = op1_op2_sum;
				end
				3'b010:begin //SLTI
					hold_flag_o = 0;
					jump_flag = 0;
					jump_addr = 0;
					mem_data_o = 0;
					mem_rd_addr_o = 0;
					mem_wr_addr_o = 0;
					mem_wr_en = 0;
					reg_data_o = comparison_signed;
				end
				3'b011:begin //SLTIU
					hold_flag_o = 0;
					jump_flag = 0;
					jump_addr = 0;
					mem_data_o = 0;
					mem_rd_addr_o = 0;
					mem_wr_addr_o = 0;
					mem_wr_en = 0;
					reg_data_o = comparison_unsigned;
				end
				3'b100:begin //XORI
					hold_flag_o = 0;
					jump_flag = 0;
					jump_addr = 0;
					mem_data_o = 0;
					mem_rd_addr_o = 0;
					mem_wr_addr_o = 0;
					mem_wr_en = 0;
					reg_data_o = op1_i ^ op2_i;
				end
				3'b110:begin //ORI
					hold_flag_o = 0;
					jump_flag = 0;
					jump_addr = 0;
					mem_data_o = 0;
					mem_rd_addr_o = 0;
					mem_wr_addr_o = 0;
					mem_wr_en = 0;
					reg_data_o = op1_i | op2_i ;
				end
				3'b111:begin //ANDI
					hold_flag_o = 0;
					jump_flag = 0;
					jump_addr = 0;
					mem_data_o = 0;
					mem_rd_addr_o = 0;
					mem_wr_addr_o = 0;
					mem_wr_en = 0;
					reg_data_o = op1_i & op2_i;
				end
				3'b001:begin //SLLI
					hold_flag_o = 0;
					jump_flag = 0;
					jump_addr = 0;
					mem_data_o = 0;
					mem_rd_addr_o = 0;
					mem_wr_addr_o = 0;
					mem_wr_en = 0;
					reg_data_o = reg1_data_i << inst_i[24:20];
				end
				3'b101:begin//SRI
					hold_flag_o = 0;
					jump_flag = 0;
					jump_addr = 0;
					mem_data_o = 0;
					mem_rd_addr_o = 0;
					mem_wr_addr_o = 0;
					mem_wr_en = 0;
					if(inst_i[30] == 1'b0) begin //SRLI
						reg_data_o = reg1_data_i >> inst_i[24:20];		
				end else begin
						reg_data_o = ({32{reg1_data_i[31]}} & ~shift_mask ) | reg_shift;
				end		
				end
				default:begin
					hold_flag_o = 0;
					jump_flag = 0;
					jump_addr = 0;
					mem_data_o = 0;
					mem_rd_addr_o = 0;
					mem_wr_addr_o = 0;
					mem_wr_en = 0;
					reg_data_o = 0;				
				end
			endcase
		end
		
		7'b0110011:begin//R type
			if((funct7 == 7'b0000000) || (funct7 == 7'b0100000)) begin
				case(funct3)
					3'b000:begin
						hold_flag_o = 0;
						jump_flag = 0;
						jump_addr = 0;
						mem_data_o = 0;
						mem_rd_addr_o = 0;
						mem_wr_addr_o = 0;
						mem_wr_en = 0;
						if(inst_i[30] == 1'b1) begin  //ADD
							reg_data_o = op1_op2_sum;	
						end
						else begin
							reg_data_o = op1_i - op2_i;
						end
					end
					3'b001:begin //SLL
						hold_flag_o = 0;
						jump_flag = 0;
						jump_addr = 0;
						mem_data_o = 0;
						mem_rd_addr_o = 0;
						mem_wr_addr_o = 0;
						mem_wr_en = 0;
						reg_data_o = op1_i << op2_i[4:0];
					end
					3'b010:begin //SLT
						hold_flag_o = 0;
						jump_flag = 0;
						jump_addr = 0;
						mem_data_o = 0;
						mem_rd_addr_o = 0;
						mem_wr_addr_o = 0;
						mem_wr_en = 0;
						reg_data_o = comparison_signed;					
					end
					3'b011:begin //SLTU
						hold_flag_o = 0;
						jump_flag = 0;
						jump_addr = 0;
						mem_data_o = 0;
						mem_rd_addr_o = 0;
						mem_wr_addr_o = 0;
						mem_wr_en = 0;
						reg_data_o = comparison_unsigned;	
					end
					3'b100:begin //XOR
						hold_flag_o = 0;
						jump_flag = 0;
						jump_addr = 0;
						mem_data_o = 0;
						mem_rd_addr_o = 0;
						mem_wr_addr_o = 0;
						mem_wr_en = 0;
						reg_data_o = op1_i ^ op2_i;					
					end
					3'b101:begin //SR
						hold_flag_o = 0;
						jump_flag = 0;
						jump_addr = 0;
						mem_data_o = 0;
						mem_rd_addr_o = 0;
						mem_wr_addr_o = 0;
						mem_wr_en = 0;
						if(inst_i[30] == 1'b0) begin //SRL
							reg_data_o = reg1_data_i >> reg2_data_i[4:0];		
						end else begin //SRA
							reg_data_o = ({32{reg1_data_i[31]}} & ~shift_mask_2 ) | reg_shift_2;
						end
					end
					3'b110:begin //OR
						hold_flag_o = 0;
						jump_flag = 0;
						jump_addr = 0;
						mem_data_o = 0;
						mem_rd_addr_o = 0;
						mem_wr_addr_o = 0;
						mem_wr_en = 0;
						reg_data_o = op1_i | op2_i;
					end
					3'b111:begin //AND
						hold_flag_o = 0;
						jump_flag = 0;
						jump_addr = 0;
						mem_data_o = 0;
						mem_rd_addr_o = 0;
						mem_wr_addr_o = 0;
						mem_wr_en = 0;
						reg_data_o = op1_i & op2_i;
					end
					default:begin
						hold_flag_o = 0;
						jump_flag = 0;
						jump_addr = 0;
						mem_data_o = 0;
						mem_rd_addr_o = 0;
						mem_wr_addr_o = 0;
						mem_wr_en = 0;
						reg_data_o = 0;
					end
				endcase
			end else begin
						hold_flag_o = 0;
						jump_flag = 0;
						jump_addr = 0;
						mem_data_o = 0;
						mem_rd_addr_o = 0;
						mem_wr_addr_o = 0;
						mem_wr_en = 0;
						reg_data_o = 0;
			end
		end
		
		7'b0000011:begin//load
			case(funct3)
				3'b000:begin //LB
					hold_flag_o = 0;
					jump_flag = 0;
					jump_addr = 0;
					mem_data_o = 0;
					mem_rd_addr_o = op1_op2_sum;
					mem_wr_addr_o = 0;
					mem_wr_en = 0;
					mem_req = 1;
					case(mem_rd_addr_index)
						2'b00:begin
							reg_data_o = {{24{mem_data_i[7]}},mem_data_i[7:0]};
						end
						2'b01:begin
							reg_data_o = {{24{mem_data_i[15]}},mem_data_i[15:8]};
						end
						2'b10:begin
							reg_data_o = {{24{mem_data_i[23]}},mem_data_i[23:16]};
						end
						2'b11:begin
							reg_data_o = {{24{mem_data_i[31]}},mem_data_i[31:24]};
						end					
					endcase
				end
				3'b001:begin  //LH
					hold_flag_o = 0;
					jump_flag = 0;
					jump_addr = 0;
					mem_data_o = 0;
					mem_rd_addr_o = op1_op2_sum;
					mem_wr_addr_o = 0;
					mem_wr_en = 0;
					mem_req = 1;
					if(mem_rd_addr_index == 2'b0) begin
						reg_data_o = {{16{mem_data_i[15]}},mem_data_i[15:0]};
					end else begin
						reg_data_o = {{16{mem_data_i[31]}},mem_data_i[31:16]};
					end
				end
				3'b010:begin //LW
					hold_flag_o = 0;
					jump_flag = 0;
					jump_addr = 0;
					mem_data_o = 0;
					mem_rd_addr_o = op1_op2_sum;
					mem_wr_addr_o = 0;
					mem_wr_en = 0;
					mem_req = 1;
					reg_data_o = mem_data_i;
				end
				3'b100:begin //LBU
					hold_flag_o = 0;
					jump_flag = 0;
					jump_addr = 0;
					mem_data_o = 0;
					mem_rd_addr_o = op1_op2_sum;
					mem_wr_addr_o = 0;
					mem_wr_en = 0;
					mem_req = 1;
					case(mem_rd_addr_index)
						2'b00:begin
							reg_data_o = {24'b0,mem_data_i[7:0]};
						end
						2'b01:begin
							reg_data_o = {24'b0,mem_data_i[15:8]};
						end
						2'b10:begin
							reg_data_o = {24'b0,mem_data_i[23:16]};
						end
						2'b11:begin
							reg_data_o = {24'b0,mem_data_i[31:24]};
						end					
					endcase
				end
				3'b101:begin //LHU
					hold_flag_o = 0;
					jump_flag = 0;
					jump_addr = 0;
					mem_data_o = 0;
					mem_rd_addr_o = op1_op2_sum;
					mem_wr_addr_o = 0;
					mem_wr_en = 0;
					mem_req = 1;
					if(mem_rd_addr_index == 2'b0) begin
						reg_data_o = {16'b0,mem_data_i[15:0]};
					end else begin
						reg_data_o = {16'b0,mem_data_i[31:16]};
					end
				end
				default:begin
					hold_flag_o = 0;
					jump_flag = 0;
					jump_addr = 0;
					mem_data_o = 0;
					mem_rd_addr_o = op1_op2_sum;
					mem_wr_addr_o = 0;
					mem_wr_en = 0;
					reg_data_o = 0;
				end
			endcase
		end
		7'b0100011:begin //store
			case(funct3)
				3'b000:begin //SB
					hold_flag_o = 0;
					jump_flag = 0;
					jump_addr = 0;
					reg_data_o = 0;
					mem_wr_addr_o = op1_op2_sum;
					mem_rd_addr_o = op1_op2_sum;
					mem_wr_en = 1;
					mem_req = 1;
					case(mem_wr_addr_index)
						2'b00:begin
							mem_data_o = {mem_data_i[31:8],reg2_data_i[7:0]};
						end
						2'b01:begin
							mem_data_o = {mem_data_i[31:16],reg2_data_i[7:0],mem_data_i[7:0]};
						end
						2'b10:begin
							mem_data_o  = {mem_data_i[31:24],reg2_data_i[7:0],mem_data_i[15:0]};
						end
						2'b11:begin
							mem_data_o  = {reg2_data_i[7:0],mem_data_i[23:0]};
						end					
					endcase
				end
				3'b001:begin //SH
					hold_flag_o = 0;
					jump_flag = 0;
					jump_addr = 0;
					reg_data_o = 0;
					mem_wr_addr_o = op1_op2_sum;
					mem_rd_addr_o = op1_op2_sum;
					mem_wr_en = 1;
					mem_req = 1;
					if (mem_wr_addr_index == 2'b00) begin
						mem_data_o = {mem_data_i[31:16], reg2_data_i[15:0]};
					end else begin
						mem_data_o = {reg2_data_i[15:0], mem_data_i[31:16]};
					end
				end
				3'b010:begin //SW
					hold_flag_o = 0;
					jump_flag = 0;
					jump_addr = 0;
					reg_data_o = 0;
					mem_wr_addr_o = op1_op2_sum;
					mem_rd_addr_o = op1_op2_sum;
					mem_wr_en = 1;
					mem_req = 1;
					mem_data_o = reg2_data_i;
				end
				default:begin
					hold_flag_o = 0;
					jump_flag = 0;
					jump_addr = 0;
					mem_data_o = 0;
					mem_rd_addr_o = 0;
					mem_wr_addr_o = 0;
					mem_wr_en = 0;
					reg_data_o = 0;
				end
			endcase
		end
		7'b1100011:begin //Branch type
			case(funct3)
				3'b000:begin //BEQ
					hold_flag_o = 0;
					jump_flag = op1_eq_op2;
					jump_addr = op1_op2_jump_sum & {32{op1_eq_op2}};
					mem_data_o = 0;
					mem_rd_addr_o = 0;
					mem_wr_addr_o = 0;
					mem_wr_en = 0;
					reg_data_o = 0;
				end
				3'b001:begin //BNE
					hold_flag_o = 0;
					jump_flag = ~op1_eq_op2;
					jump_addr = op1_op2_jump_sum & {32{~op1_eq_op2}};
					mem_data_o = 0;
					mem_rd_addr_o = 0;
					mem_wr_addr_o = 0;
					mem_wr_en = 0;
					reg_data_o = 0;
				end
				3'b100:begin //BLT
					hold_flag_o = 0;
					jump_flag = comparison_signed[0];
					jump_addr = op1_op2_jump_sum & {32{comparison_signed[0]}};
					mem_data_o = 0;
					mem_rd_addr_o = 0;
					mem_wr_addr_o = 0;
					mem_wr_en = 0;
					reg_data_o = 0;
				end
				3'b101:begin //BGE
					hold_flag_o = 0;
					jump_flag = ~comparison_signed[0];
					jump_addr = op1_op2_jump_sum & {32{~comparison_signed[0]}};
					mem_data_o = 0;
					mem_rd_addr_o = 0;
					mem_wr_addr_o = 0;
					mem_wr_en = 0;
					reg_data_o = 0;
				end
				3'b110:begin //BLTU
					hold_flag_o = 0;
					jump_flag = comparison_unsigned[0];
					jump_addr = op1_op2_jump_sum & {32{comparison_unsigned[0]}};
					mem_data_o = 0;
					mem_rd_addr_o = 0;
					mem_wr_addr_o = 0;
					mem_wr_en = 0;
					reg_data_o = 0;
				end
				3'b111:begin //BGEU
					hold_flag_o = 0;
					jump_flag = ~comparison_unsigned[0];
					jump_addr = op1_op2_jump_sum & {32{~comparison_unsigned[0]}};
					mem_data_o = 0;
					mem_rd_addr_o = 0;
					mem_wr_addr_o = 0;
					mem_wr_en = 0;
					reg_data_o = 0;
				end
				default:begin
					hold_flag_o = 0;
					jump_flag = 0;
					jump_addr = 0;
					mem_data_o = 0;
					mem_rd_addr_o = 0;
					mem_wr_addr_o = 0;
					mem_wr_en = 0;
					reg_data_o = 0;
				end
			endcase
		end
		
		7'b1101111:begin //JAL
			hold_flag_o = 0;
			jump_flag = 1;
			jump_addr = op1_op2_jump_sum;
			mem_data_o = 0;
			mem_rd_addr_o = 0;
			mem_wr_addr_o = 0;
			mem_wr_en = 0;
			reg_data_o = op1_op2_sum;
		end
		7'b1100111:begin //JALR
			hold_flag_o = 0;
			jump_flag = 1;
			jump_addr = op1_op2_jump_sum;
			mem_data_o = 0;
			mem_rd_addr_o = 0;
			mem_wr_addr_o = 0;
			mem_wr_en = 0;
			reg_data_o = op1_op2_sum;
		end
		7'b0110111:begin//LUI
			hold_flag_o = 0;
			jump_flag = 0;
			jump_addr = 0;
			mem_data_o = 0;
			mem_rd_addr_o = 0;
			mem_wr_addr_o = 0;
			mem_wr_en = 0;
			reg_data_o = op1_i;
		end
		7'b0010111:begin//AUIPC
			hold_flag_o = 0;
			jump_flag = 0;
			jump_addr = 0;
			mem_data_o = 0;
			mem_rd_addr_o = 0;
			mem_wr_addr_o = 0;
			mem_wr_en = 0;
			reg_data_o = op1_op2_sum;
		end
		7'b0000001:begin//NOP
			hold_flag_o = 0;
			jump_flag = 0;
			jump_addr = 0;
			mem_data_o = 0;
			mem_rd_addr_o = 0;
			mem_wr_addr_o = 0;
			mem_wr_en = 0;
			reg_data_o = 0;
		end
		7'b0001111:begin//FENCE
			hold_flag_o = 0;
			jump_flag = 1;
			jump_addr = op1_op2_jump_sum;
			mem_data_o = 0;
			mem_rd_addr_o = 0;
			mem_wr_addr_o = 0;
			mem_wr_en = 0;
			reg_data_o = 0;
		end
		7'b1110011:begin//CSR
			hold_flag_o = 0;
			jump_flag = 0;
			jump_addr = 0;
			mem_data_o = 0;
			mem_rd_addr_o = 0;
			mem_wr_addr_o = 0;
			mem_wr_en = 0;
			case(funct3)
				3'b001:begin//CSRRW
					reg_data_o = csr_data_i;
					csr_data_o = reg1_data_i;
				end
				3'b010:begin//CSRRS
					reg_data_o = csr_data_i; 
					csr_data_o = reg1_data_i | csr_data_i;
				end
				3'b011:begin//CSRRC
					reg_data_o = csr_data_i; 
					csr_data_o = (~reg1_data_i) & csr_data_i;
				end
				3'b101:begin//CSRRWI
					reg_data_o = csr_data_i; 
					csr_data_o = {27'b0,uimm};
				end
				3'b110:begin//CSRRSI
					reg_data_o = csr_data_i; 
					csr_data_o = {27'b0,uimm} | csr_data_i;
				end
				3'b111:begin//CSRRCI
					reg_data_o = csr_data_i; 
					csr_data_o = (~{27'b0,uimm}) & csr_data_i;
				end
				default:begin
					reg_data_o = 0;
				end
			endcase
		end
		default:begin
			hold_flag_o = 0;
			jump_flag = 0;
			jump_addr = 0;
			mem_data_o = 0;
			mem_rd_addr_o = 0;
			mem_wr_addr_o = 0;
			mem_wr_en = 0;
			reg_data_o = 0;
		end
	endcase
	
end

endmodule