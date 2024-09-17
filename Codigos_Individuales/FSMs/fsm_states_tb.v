`timescale 1ns / 1ps
`include "/home/juandavidgm/github-classroom/unal-edigital1-lab/PROYECTO/entrega-1-proyecto-grupo20-2024-1/Codigos_Individuales/FSMs/fsm_states.v"

module fsm_states_tb;
    // Inputs
    reg clk;
    reg rst;
	reg feeding;
	reg echo_sig;
	reg light_out;
	reg healing;
    reg change_state;
    reg test;
    // Outputs
    wire [2:0] foodValue;
	wire [2:0] sleepValue;
	wire [2:0] funValue;
	wire [2:0] happyValue;
	wire [2:0] healthValue;

	// Instantiate the Unit Under Test (UUT)

	fsm_states uut (
		.clk(clk),
		.rst(rst),
		.feeding(feeding),
		.healing(healing),
		.light_out(light_out),
		.echo_sig(echo_sig),
		.change_state(change_state),
		.test(test),
		.foodValue(foodValue),
		.sleepValue(sleepValue),
		.funValue(funValue),
		.happyValue(happyValue),
		.healthValue(healthValue)
	);

	initial begin
		//Initialize Inputs
		clk = 0;
		rst = 0;
		feeding = 0;
		light_out = 0;
		echo_sig = 0;
		healing = 0;
		change_state = 0;
		test = 0;
		//#10000 es un segundo
		#10;// Wait 100 ns for global reset to finish
		/*
		rst = 1;
		test = 1;
		@(posedge clk);
		@(negedge clk);
		test = 0;
		feeding = 1;
		@(posedge clk);
		@(negedge clk);
		feeding = 0;
		@(posedge clk);
		@(negedge clk);
		healing = 1;
		@(posedge clk);
		@(negedge clk);
		healing = 0;
		@(posedge clk);
		@(negedge clk);
		healing = 1;
		@(posedge clk);
		@(negedge clk);
		healing = 0;
		@(posedge clk);
		@(negedge clk);
		healing = 1;
		@(posedge clk);
		@(negedge clk);
		healing = 0;
		change_state = 1;
		@(posedge clk);
		@(negedge clk);
		change_state = 0;
		@(posedge clk);
		@(negedge clk);
		healing = 1;
		@(posedge clk);
		@(negedge clk);
		healing = 0;
		@(posedge clk);
		@(negedge clk);
		change_state = 1;
		@(posedge clk);
		@(negedge clk);
		change_state = 0;
		@(posedge clk);
		@(negedge clk);
		healing = 1;
		@(posedge clk);
		@(negedge clk);
		healing = 0;
		@(posedge clk);
		@(negedge clk);
		change_state = 1;
		@(posedge clk);
		@(negedge clk);
		change_state = 0;
		@(posedge clk);
		@(negedge clk);
		healing = 1;
		@(posedge clk);
		@(negedge clk);
		healing = 0;
		@(posedge clk);
		@(negedge clk);
		change_state = 1;
		@(posedge clk);
		@(negedge clk);
		change_state = 0;
		@(posedge clk);
		@(negedge clk);
		healing = 1;
		@(posedge clk);
		@(negedge clk);
		healing = 0;
		@(posedge clk);
		@(negedge clk);
		change_state = 1;
		@(posedge clk);
		@(negedge clk);
		change_state = 0;
		@(posedge clk);
		@(negedge clk);
		change_state = 1;
		@(posedge clk);
		@(negedge clk);
		change_state = 0;
		@(posedge clk);
		@(negedge clk);
		healing = 1;
		@(posedge clk);
		@(negedge clk);
		healing = 0;
		@(posedge clk);
		@(negedge clk);
		healing = 1;
		@(posedge clk);
		@(negedge clk);
		healing = 0;
		@(posedge clk);
		@(negedge clk);
		feeding = 1;
		@(posedge clk);
		@(negedge clk);
		feeding = 0;
		@(posedge clk);
		@(negedge clk);
		change_state = 1;
		@(posedge clk);
		@(negedge clk);
		change_state = 0;
		@(posedge clk);
		@(negedge clk);
		change_state = 1;
		@(posedge clk);
		@(negedge clk);
		change_state = 0;
		@(posedge clk);
		@(negedge clk);
		healing = 1;
		@(posedge clk);
		@(negedge clk);
		healing = 0;
		@(posedge clk);
		@(negedge clk);
		test = 1;
		@(posedge clk);
		@(negedge clk);
		test = 0;
		*/
	end

	always #1 clk = ~clk;

	initial begin: TEST_CASE
	    $dumpfile("fsm_states.vcd");
		$dumpvars(-1, uut);
		#10000 $finish;
	end
	   
endmodule

