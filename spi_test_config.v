`timescale 1ns / 1ps

module spi_test_config;

	 reg clk;
    reg reset;
	 reg [3:0]draw;
	 
    wire mosi;

    // Outputs
    wire dc;
    wire sclk;
    wire sce;

	 spi_configBunny uut(
		.clock(clk),
		.Reset(reset),
		.draw(draw),
		.mosi(mosi),
		.sclk(sclk),
		.sce(sce),
		.dc(dc)
		
	);
	
	initial begin
        clk = 0;
        forever #1 clk = ~clk; //500Mhz
   	end
	 
	initial begin
		reset=0; //se presiona reset primero para reinicializar todo
		#200;
		reset=1;
		
		draw<=4'h3;
		
	end
	
endmodule
