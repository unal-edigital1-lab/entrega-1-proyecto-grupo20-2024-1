`timescale 1ns / 1ps

module spi_test_config;

	 reg clk;
    reg reset;
    wire mosi;

    // Outputs
	 wire dc;
    wire sclk;
    wire sce;
	 wire [2:0] test;
	 wire [7:0] message;
	 
	 spi_config uut(
		.clock(clk),
		.Reset(reset),

		.mosi(mosi),
		.sclk(sclk),
		.sce(sce),
		.dc(dc),
		.test(test),
		.message(message)
	);
	
	
	initial begin
        clk = 0;
        forever #1 clk = ~clk; //500Mhz
    end
	 
	initial begin
		reset=1; //se presiona reset primero para reinicializar todo
		#200;
		reset=0;
		
		//$display("mosi %d", mosi);
		
		//#10000; 
		#8000;
		$stop;

	end
	
	
endmodule
