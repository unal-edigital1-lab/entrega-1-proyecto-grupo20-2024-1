`timescale 10ns/1ps

module testbench_core;

	reg clk;
	reg reset;

	
	core uut(
	.clock(clk),
	.Reset(reset)
	);
	
	initial begin 
	clk=0;
	forever #1 clk = ~clk; 
	end
	
	initial begin
		reset=0; //se presiona reset primero para reinicializar todo
		#200;
		reset=1;
	end
		
	
	endmodule
	
