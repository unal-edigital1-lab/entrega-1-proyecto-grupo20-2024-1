`timescale 1ns / 1ps

module spi_test_config;

	 reg clk;
    reg reset;
    wire mosi;

    // Outputs
	 wire dc;
    wire sclk;
    wire sce;
	 wire [7:0] message;
	 
	 spi_configBunny uut(
		.clock(clk),
		.Reset(reset),

		.mosi(mosi),
		.sclk(sclk),
		.sce(sce),
		.dc(dc),
		.message(message)
	);
	
	
	initial begin
        clk = 0;
        forever #1 clk = ~clk; //500Mhz
    end
	 
	initial begin
		reset=0; //se presiona reset primero para reinicializar todo
		#200;
		reset=1;
		
		//$display("mosi %d", mosi);
		
		
		//#10000;
		//$stop;

	end
	
	
endmodule
