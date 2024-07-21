module decode(
input rst_n,
input [31:0] inst_i,
input [31:0] inst_addr_i,
input [31:0] reg1_data_i,
input [31:0] reg2_data_i,
input [31:0] csr_data_i,
output reg [4:0] reg1_addr_o,
output reg [4:0] reg2_addr_o,
output reg [31:0] csr_rd_addr_o,
output reg [31:0] op1_o,
output reg [31:0] op2_o,
output reg [31:0] op1_jump_o,
output reg [31:0] op2_jump_o, 
//output reg mem_req,
output reg [31:0] inst_o,
output reg [31:0] inst_addr_o,
output reg [31:0] reg1_data_o,
output reg [31:0] reg2_data_o,
output reg reg_wr_en_o,
output reg [4:0] reg_wr_addr_o,
output reg csr_wr_en_o,
output reg [31:0] csr_data_o,
output reg [31:0] csr_wr_addr_o
);

wire [6:0] opcode = inst_i[6:0];
wire [4:0] rd = inst_i[11:7];
wire [2:0] funct3 = inst_i[14:12];
wire [4:0] rs1 = inst_i[19:15];
wire [4:0] rs2 = inst_i[24:20];
wire [6:0] funct7 = inst_i[31:25];

always@(*) begin
    inst_o = inst_i;
    inst_addr_o = inst_addr_i;
    reg1_data_o = reg1_data_i;
    reg2_data_o = reg2_data_i;
    csr_data_o = csr_data_i;
    csr_rd_addr_o = 0;
    csr_wr_addr_o = 0;
    csr_wr_en_o = 0;
    op1_o = 0;
	 op2_o = 0;
	 op1_jump_o = 0;
	 op2_jump_o = 0;
	 
	 case(opcode)
		7'b0010011:begin  //I type
			case(funct3)
				3'b000,3'b010,3'b011,3'b100,3'b110,3'b111,3'b001,3'b101:
				begin
					reg_wr_en_o = 1;
					reg_wr_addr_o = rd;
					reg1_addr_o = rs1;
					reg2_addr_o = 0;
					op1_o = reg1_data_i;
					op2_o = {{20{inst_i[31]}}, inst_i[31:20]};
				end
				
				default: 
				begin
                reg_wr_en_o = 0;
                reg_wr_addr_o = 0;
                reg1_addr_o = 0;
                reg2_addr_o = 0;
					 op1_o = 0;
					 op2_o = 0;
            end
			endcase
		end
		
		7'b0110011:begin//R type
			if((funct7 == 7'b000000) || (funct7 == 7'b0100000)) begin  //base instruction
				case (funct3)
					3'b000,3'b010,3'b011,3'b100,3'b110,3'b111,3'b001,3'b101:
					begin
						reg_wr_en_o = 1;
						reg_wr_addr_o = rd;
						reg1_addr_o = rs1;
						reg2_addr_o = rs2;
						op1_o = reg1_data_i;
						op2_o = reg2_data_i;
					end
					
					default:
					begin
						reg_wr_en_o = 0;
						reg_wr_addr_o = 0;
						reg1_addr_o = 0;
						reg2_addr_o = 0;
						op1_o = 0;
						op2_o = 0;
					end
				endcase
			end
//			else if (funct7 == 7'b0000001) begin//standard extension 
//				case(funct3)
//					3'b000,3'b001,3'b010,3'b011:begin  //multiplication
//						reg_wr_en_o = 1;
//						reg_wr_addr_o = rd;
//						reg1_addr_o = rs1;
//						reg2_addr_o = rs2;
//						op1_o = reg1_data_i;
//						op2_o = reg2_data_i;
//					end
//					
//					3'b100, 3'b101, 3'b110, 3'b111:begin // division, may change later
//						reg_wr_en_o = 1;
//						reg_wr_addr_o = rd;
//						reg1_addr_o = rs1;
//						reg2_addr_o = rs2;
//						op1_o = reg1_data_i;
//						op2_o = reg2_data_i;
//					end
//					
//					default:
//					begin
//						reg_wr_en_o = 0;
//						reg_wr_addr_o = 0;
//						reg1_addr_o = 0;
//						reg2_addr_o = 0;
//						op1_o = 0;
//						op2_o = 0;
//					end
//				endcase
//			end
		end
		7'b0000011:begin//load
			case(funct3)
				3'b000,3'b001,3'b010,3'b100,3'b101:begin
					reg1_addr_o = rs1;
					reg2_addr_o = 0;
					reg_wr_en_o = 1;
					reg_wr_addr_o = rd;
					op1_o = reg1_data_i;
					op2_o = {{20{inst_i[31]}},inst_i[31:20]};
				end
				default:begin
					reg_wr_en_o = 0;
					reg_wr_addr_o = 0;
					reg1_addr_o = 0;
					reg2_addr_o = 0;
					op1_o = 0;
					op2_o = 0;
				end
			endcase
		end
		
		7'b0100011:begin//store
			case(funct3)
				3'b000,3'b001,3'b010:begin
					reg1_addr_o = rs1;
					reg2_addr_o = rs2;
					reg_wr_en_o = 0; 
					reg_wr_addr_o = 0;
					op1_o = reg1_data_i ;
					op2_o = {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
				end
				default:begin
					reg_wr_en_o = 0;
					reg_wr_addr_o = 0;
					reg1_addr_o = 0;
					reg2_addr_o = 0;
					op1_o = 0;
					op2_o = 0;
				end
			endcase
		end
		
		7'b1100011:begin//Branch type
			case(funct3)
				3'b000,3'b001,3'b100,3'b101,3'b110,3'b111:begin
					reg1_addr_o = rs1;
					reg2_addr_o = rs2;
					reg_wr_en_o = 0;
					reg_wr_addr_o = 0;
					op1_o = reg1_data_i;
					op2_o = reg2_data_i;
					op1_jump_o = inst_addr_i;
					op2_jump_o = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
				end
				default:begin
					reg_wr_en_o = 0;
					reg_wr_addr_o = 0;
					reg1_addr_o = 0;
					reg2_addr_o = 0;
					op1_o = 0;
					op2_o = 0;
				end
			endcase
		end
		
		7'b1101111:begin//JAL
			reg1_addr_o = 0;
			reg2_addr_o = 0;
			reg_wr_en_o = 1;
			reg_wr_addr_o = rd;
			op1_o = inst_addr_i;
			op2_o = 32'h4;
			op1_jump_o = inst_addr_i;
			op2_jump_o = {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
		end
		
		7'b1100111:begin//JALR
			reg1_addr_o = rs1;
			reg2_addr_o = 0;
			reg_wr_en_o = 1;
			reg_wr_addr_o = rd;
			op1_o = inst_addr_i;
			op2_o = 32'h4;
			op1_jump_o = reg1_data_i;
			op2_jump_o = {{20{inst_i[31]}}, inst_i[31:20]};
		end
		
		7'b0110111:begin//LUI
			reg_wr_en_o = 1;
			reg_wr_addr_o = rd; 
			reg1_addr_o = 0;
			reg2_addr_o = 0;
			op1_o = {inst_i[31:12], 12'b0};
			op2_o = 0;
		end
		
		7'b0010111:begin//AUIPC
			reg_wr_en_o = 1;
			reg_wr_addr_o = rd; 
			reg1_addr_o = 0;
			reg2_addr_o = 0;
			op1_o = {inst_i[31:12], 12'b0};
			op2_o = inst_addr_i;
		end
		
		7'b0000001:begin//NOP
			reg_wr_en_o = 0;
			reg_wr_addr_o = 0;
			reg1_addr_o = 0;
			reg2_addr_o = 0;
			op1_o = 0;
			op2_o = 0;
		end
		
		7'b0001111:begin//FENCE
			reg_wr_en_o = 0;
			reg_wr_addr_o = 0;
			reg1_addr_o = 0;
			reg2_addr_o = 0;
			op1_jump_o = inst_addr_i;
			op2_jump_o = 32'h4;
		end
		
		7'b1110011:begin//CSR
			reg_wr_en_o = 0;
			reg_wr_addr_o = 0;
			reg1_addr_o = 0;
			reg2_addr_o = 0;
			csr_rd_addr_o = {20'h0, inst_i[31:20]};
         csr_wr_addr_o = {20'h0, inst_i[31:20]};
			case(funct3)
				3'b001,3'b010,3'b011:begin
					reg1_addr_o = rs1;
					reg2_addr_o = 0;
					reg_wr_en_o = 1;
					reg_wr_addr_o = rd;
					csr_wr_en_o = 1;
				end
				3'b101,3'b110,3'b111:begin
					reg1_addr_o = 0;
					reg2_addr_o = 0;
					reg_wr_en_o = 1;
					reg_wr_addr_o = rd;
					csr_wr_en_o = 1;
				end
				
				default:begin
					reg_wr_en_o = 0;
					reg_wr_addr_o = 0;
					reg1_addr_o = 0;
					reg2_addr_o = 0;
					csr_wr_en_o = 0;
				end
			endcase
		end
		default:begin
			reg_wr_en_o = 0;
			reg_wr_addr_o = 0;
			reg1_addr_o = 0;
			reg2_addr_o = 0;
			csr_wr_en_o = 0;
		end
	 endcase
end

endmodule
