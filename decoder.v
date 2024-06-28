module decoder(
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
output reg [31:0] csr_rd_data_o,
output reg [31:0] csr_wr_add_o
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
    csr_rd_data_o = csr_data_i;
    csr_rd_addr_o = 0;
    csr_wr_add_o = 0;
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
					reg_wr_en_o <= 1;
					reg_wr_addr_o <= rd;
					reg1_addr_o <= rs1;
					reg2_addr_o <= 0;
					op1_o <= reg1_data_i;
					op2_o <= {{20{inst_i[31]}}, inst_i[31:20]};
				end
				
				default: 
				begin
                reg_wr_en_o <= 0;
                reg_wr_addr_o <= 0;
                reg1_addr_o <= 0;
                reg2_addr_o <= 0;
					 op1_o <= 0;
					 op2_o <= 0;
            end
			endcase
		end
	 endcase
end

endmodule