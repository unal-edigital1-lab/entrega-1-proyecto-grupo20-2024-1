`timescale 10ns / 1ps

module tb_tamagotchi_v2;
	reg clk;
	reg reset;
	reg done;
	
	reg testBut;
	reg feeding;
	reg healing;
	
	tamagotchi_v2 uut(
	.Clk(clk),
	.Rst(reset), 
	.testBut(testBut),
	.feeding(feeding),
	.healing(healing)
	);
	
	initial begin 
	clk=0;
	forever #1 clk = ~clk; 
	end
	
	/*
	initial begin 
	done=0;
	forever #5 done = ~done; 
	end
	*/
	
	initial begin
		reset=0; //se presiona reset primero para reinicializar todo
		testBut=0;
		
		#200;
		reset=1;
		
		#5500;
		feeding=1;
		#1000;
		feeding=0;
		
		#6000;
		healing=1;
		
		
	end
		
	
	endmodule