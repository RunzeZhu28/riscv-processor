module spi(
input clk,
input rst_n,
input [31:0] data_i,
input [31:0] addr_i,
input wr_en_i,
output reg [31:0] data_o,
output reg mosi,
input miso,
output ss,
output reg sck
);

localparam SPI_CTRL = 4'h0;
localparam SPI_DATA = 4'h4;
localparam SPI_STATUS = 4'h8;

reg [31:0] spi_ctrl;
//[0]: 1: enable spi
//[1]: CPOL
//[2]: CPHA
//[3]: 1: select slave
//[15:8]: clk div

reg [31:0] spi_data; //[7:0] cmd or data

reg [31:0] spi_status;//[0] 1:busy
reg [8:0] clk_cnt;
reg en;
reg [4:0] clk_edge_cnt;
reg clk_edge_level;
reg [7:0] rd_data;
reg done;
reg [3:0] index;
wire [8:0] div_cnt;

assign ss = ~spi_ctrl[3];//active low
assign div_cnt = spi_ctrl[15:8];

always@(posedge clk) begin
	if(rst_n == 0) begin
		en <= 0;
	end else if (spi_ctrl[0] == 1) begin
		en <= 1;
	end else if (done == 1) begin
		en <= 1'b0;
	end else begin
		en <= en;
	end
end

always@(posedge clk) begin
	if(rst_n == 1'b0) begin
		clk_cnt <= 9'b0;
	end else if(en == 1'b1) begin
		if(clk_cnt == div_cnt) begin
			clk_cnt <= 9'b0;
		end else begin
			clk_cnt <= clk_cnt + 1'b1;
		end
	end else begin
		clk_cnt <= 9'b0;
	end
end

always@(posedge clk) begin
	if(rst_n === 1'b0) begin
		clk_edge_cnt <= 5'b0;
		clk_edge_level <= 1'b0;
	end else if (en == 1'b1) begin
		if (clk_cnt == div_cnt) begin
			if(clk_edge_cnt == 5'd17) begin
				clk_edge_cnt <= 5'h0;
				clk_edge_level <= 1'b0;
			end else begin
				clk_edge_cnt <= clk_edge_cnt + 1'b1;
				clk_edge_level <= 1'b1;
			end
		end else begin
			clk_edge_level <= 1'b0;
		end
	end else begin
		clk_edge_cnt <= 5'b0;
		clk_edge_level <= 1'b0;
	end
end

always@(posedge clk) begin
	if (rst_n == 1'b0) begin
		sck <= 1'b0;
		rd_data <= 8'b0;
		mosi <= 1'b0;
		index <= 4'b0;
	end else if (en == 1'b1) begin
		if (clk_edge_level == 1'b1) begin
			case (clk_edge_cnt)
				1,3,5,7,9,11,13,15:begin // first edge
					sck <= ~sck;
					if (spi_ctrl[2] == 1'b0) begin //Read 
						rd_data <= {rd_data[6:0],miso};
					end else begin
						index <= index - 1;
						mosi <= spi_data[index];
					end
				end
				2,4,6,8,10,12,14,16:begin //second edge
					sck <= ~sck;
					if (spi_ctrl[2] == 1'b0) begin //Write
						index <= index - 1;
						mosi <= spi_data[index];
					end else begin
						rd_data <= {rd_data[6:0],miso};
					end
				end
				17: begin
					sck <= spi_ctrl[1];
				end
				default: begin
				end
			endcase
		end else begin
			sck <= spi_ctrl[1];
			if (spi_ctrl[2] == 1'b0) begin
				mosi <= spi_data[7];
				index <= 4'h6;
			end else begin
				index <= 4'h7;
			end
		end
	end
end

always@(posedge clk) begin
	if (rst_n == 1'b0) begin
		done <= 1'b0;
	end else if(en && clk_edge_cnt == 5'd17) begin
		done <= 1'b1;
	end else begin
		done <= 1'b0;
	end
end

always@(posedge clk) begin
	if (rst_n == 1'b0) begin
		spi_ctrl <= 32'h0;
		spi_data <= 32'h0;
		spi_status <= 32'h0;
	end else begin
		spi_status[0] <= en;
		if(wr_en_i == 1'b1) begin
			case(addr_i[3:0])
				SPI_CTRL:begin
					spi_ctrl <= data_i;
				end
				SPI_DATA:begin
					spi_data <= data_i;
				end
				default:begin
				end
			endcase
		end else begin
			spi_ctrl[0] <= 1'b0;
			if (done == 1'b1) begin
				spi_data <= {24'b0, rd_data};
			end
		end
	end
end

always@(*) begin
	if(rst_n == 1'b0) begin
		data_o = 32'b0;
	end else begin
		case(addr_i[3:0])
		SPI_CTRL: begin
			data_o = spi_ctrl;
		end
		SPI_DATA: begin
			data_o = spi_data;
		end
		SPI_STATUS: begin
			data_o = spi_status;
		end
		default:begin
			data_o = 32'b0;
		end
		endcase
	end
end
endmodule