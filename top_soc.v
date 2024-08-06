module top_soc(
input clk,
input rst_n,
input uart_rx_pin,
output uart_tx_pin,
inout [1:0] gpio,
input spi_miso,
output spi_mosi,
output spi_ss,
output spi_sck
);

wire [31:0] m0_addr_i; //rib
wire [31:0] m0_data_i;
wire [31:0] m0_data_o;
wire m0_req_i;
wire m0_wr_en_i;

wire [31:0] m1_addr_i; //pc
wire [31:0] m1_data_i;
wire [31:0] m1_data_o;
wire m1_req_i;
wire m1_wr_en_i;

wire [31:0] m2_addr_i; //jtag
wire [31:0] m2_data_i;
wire [31:0] m2_data_o;
wire m2_req_i;
wire m2_wr_en_i;

wire [31:0] m3_addr_i; //uart
wire [31:0] m3_data_i;
wire [31:0] m3_data_o;
wire m3_req_i;
wire m3_wr_en_i;

wire [31:0] s0_addr_o; //ROM
wire [31:0] s0_data_o;
wire [31:0] s0_data_i;
wire s0_wr_en_o;

wire [31:0] s1_addr_o; //RAM
wire [31:0] s1_data_o;
wire [31:0] s1_data_i;
wire s1_wr_en_o;

wire [31:0] s2_addr_o; //timer
wire [31:0] s2_data_o;
wire [31:0] s2_data_i;
wire s2_wr_en_o;

wire [31:0] s3_addr_o; //uart
wire [31:0] s3_data_o;
wire [31:0] s3_data_i;
wire s3_wr_en_o;

wire [31:0] s4_addr_o; //gpio
wire [31:0] s4_data_o;
wire [31:0] s4_data_i;
wire s4_wr_en_o;

wire [31:0] s5_addr_o; //spi
wire [31:0] s5_data_o;
wire [31:0] s5_data_i;
wire s5_wr_en_o;

wire rib_hold_flag_o;
wire [7:0] interrupt_flag;
wire timer_interrupt;

wire [1:0] io_pin_i;
wire [31:0] gpio_ctrl;
wire [31:0] gpio_data;

assign gpio[0] = (gpio_ctrl[1:0] == 2'b01) ? gpio_data[0] : 1'bz; //bidirectional buffer
assign io_pin_i[0] = gpio[0];

assign gpio[1] = (gpio_ctrl[3:2] == 2'b01) ? gpio_data[1] : 1'bz;
assign io_pin_i[1] = gpio[1];

assign interrupt_flag = {7'b0,timer_interrupt};

core core_inst(
.clk(clk),
.rst_n(rst_n),
.perip_addr_o(m0_addr_i),
.perip_data_i(m0_data_o),
.perip_data_o(m0_data_i),
.perip_req_o(m0_req_i),
.perip_wr_en_o(m0_wr_en_i),
.inst_addr_o(m1_addr_i),
.inst_data_i(m1_data_o),
.jtag_reg_addr_i(),
.jtag_reg_data_i(),
.jtag_reg_wr_en_i(),
.jtag_reg_data_o(),
.rib_hold_flag_i(rib_hold_flag_o),
.jtag_halt_flag_i(),
.jtag_reset_flag_i(),
.interrupt_i(interrupt_flag)
);

rom rom_inst(
.clk(clk),
.rst_n(rst_n),
.wr_en_i(s0_wr_en_o),
.addr_i(s0_addr_o),
.data_i(s0_data_o),
.data_o(s0_data_i)
);

ram ram_inst(
.clk(clk),
.rst_n(rst_n),
.wr_en_i(s1_wr_en_o),
.addr_i(s1_addr_o),
.data_i(s1_data_o),
.data_o(s1_data_i)
);

timer timer_inst(
.clk(clk),
.rst_n(rst_n),
.data_i(s2_data_o),
.addr_i(s2_addr_o),
.wr_en_i(s2_wr_en_o),
.data_o(s2_data_i),
.interrupt_o(timer_interrupt)
);

//gpio gpio_inst(
//.clk(clk),
//.rst_n(rst_n),
//.wr_en_i(s4_wr_en_o),
//.addr_i(s4_addr_o),
//.data_i(s4_data_o),
//.data_o(s4_data_i),
//.io_pin_i(io_pin_i),
//.reg_ctrl(gpio_ctrl),
//.reg_data(gpio_data)
//);

//spi spi_inst(
//.clk(clk),
//.rst_n(rst_n),
//.data_i(s5_data_o),
//.addr_i(s5_addr_o),
//.wr_en_i(s5_wr_en_o),
//.data_o(s5_data_i),
//.mosi(spi_mosi),
//.miso(spi_miso),
//.ss(spi_ss),
//.sck(spi_sck)
//);  

rib rib_inst(
.clk(clk),
.rst_n(rst_n),
.m0_addr_i(m0_addr_i),
.m0_data_i(m0_data_i),
.m0_data_o(m0_data_o),
.m0_req_i(m0_req_i),
.m0_wr_en_i(m0_wr_en_i),
.m1_addr_i(m1_addr_i),
.m1_data_i(0),
.m1_data_o(m1_data_o),
.m1_req_i(1),
.m1_wr_en_i(0),
.m2_addr_i(m2_addr_i),
.m2_data_i(m2_data_i),
.m2_data_o(m2_data_o),
.m2_req_i(m2_req_i),
.m2_wr_en_i(m2_wr_en_i),
.m3_addr_i(m3_addr_i),
.m3_data_i(m3_data_i),
.m3_data_o(m3_data_o),
.m3_req_i(m3_req_i),
.m3_wr_en_i(m3_wr_en_i),
.s0_addr_o(s0_addr_o),
.s0_data_o(s0_data_o),
.s0_data_i(s0_data_i),
.s0_wr_en_o(s0_wr_en_o),
.s1_addr_o(s1_addr_o),
.s1_data_o(s1_data_o),
.s1_data_i(s1_data_i),
.s1_wr_en_o(s1_wr_en_o),
.s2_addr_o(s2_addr_o),
.s2_data_o(s2_data_o),
.s2_data_i(s2_data_i),
.s2_wr_en_o(s2_wr_en_o),
.s3_addr_o(s3_addr_o),
.s3_data_o(s3_data_o),
.s3_data_i(s3_data_i),
.s3_wr_en_o(s3_wr_en_o),
.s4_addr_o(s4_addr_o),
.s4_data_o(s4_data_o),
.s4_data_i(s4_data_i),
.s4_wr_en_o(s4_wr_en_o),
.s5_addr_o(s5_addr_o),
.s5_data_o(s5_data_o),
.s5_data_i(s5_data_i),
.s5_wr_en_o(s5_wr_en_o),
.hold_flag_o(rib_hold_flag_o)
);
endmodule