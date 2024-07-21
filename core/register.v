module register(
	input clk,
	input rst_n,
	input wr_en_i,
	input [4:0] wr_add_i,
	input [31:0] wr_data_i,
	input jtag_en_i,
	input [4:0] jtag_add_i,
	input [31:0] jtag_data_i,
	input [4:0] r_add1_i,
	input [4:0] r_add2_i,
	output reg [31:0] r_data1_o,
	output reg [31:0] r_data2_o,
	output reg [31:0] jtag_data_o
);

reg [31:0] regs [0:31];
always@(posedge clk)
begin
	if(rst_n != 0)
	begin
		if(wr_en_i && wr_add_i != 0)
		begin
			regs[wr_add_i] <= wr_data_i ;
		end
		
		else if( jtag_en_i && wr_add_i != 0)
		begin
			regs[jtag_add_i] <= jtag_data_i ;
		end
	end
end

always@(*)
begin
	if(rst_n == 0)
	begin
		r_data1_o <= 0;
	end
	
	else if (r_add1_i == 0)
	begin
		r_data1_o <= 0;
	end
	
	else if (r_add1_i == wr_add_i && wr_en_i)
	begin
		r_data1_o <= wr_data_i;
	end
	
	else 
		r_data1_o <= regs[r_add1_i];
end

always@(*)
begin
	if(rst_n == 0)
	begin
		r_data2_o <= 0;
	end
	
	else if (r_add2_i == 0)
	begin
		r_data2_o <= 0;
	end
	
	else if (r_add2_i == wr_add_i && wr_en_i)
	begin
		r_data2_o <= wr_data_i;
	end
	
	else 
		r_data2_o <= regs[r_add2_i];
	
end

always@(*)
begin
	if(rst_n == 0)
	begin
		jtag_data_o <= 0;
	end
	
	else if (jtag_add_i == 0)
	begin
		r_data2_o <= 0;
	end
	
	else if (jtag_add_i == wr_add_i && wr_en_i)
	begin
		jtag_data_o <= wr_data_i;
	end
	
	else 
		jtag_data_o <= regs[jtag_add_i];
end

endmodule
