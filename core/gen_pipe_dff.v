module gen_pipe_dff #(parameter width = 32)(
input clk,
input rst_n,
input hold_en,
input [width-1:0] val,
input [width-1:0] din,
output [width-1:0] qout
);

reg[width-1:0] qout_i;

always@(posedge clk) 
begin
	if(!rst_n | hold_en)
	begin
		qout_i <= val;
	end
	else begin
		qout_i <= din;
	end
end

assign qout = qout_i;

endmodule
