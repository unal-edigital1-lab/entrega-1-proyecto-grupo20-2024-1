`timescale 1ns / 1ps

module fsm_button(
    input clk,
    input rst,
	 input light_out,
    input echo_sig,
    input test_mode, 
    input button_food,
    input button_heal,
	 input change_butt,
	 output [0:6] sseg7,
	 output [2:0] an_1,
	 output [2:0] an1_1,
	 output Led
    );

	 wire [2:0] foodValueF;
	 wire [2:0] sleepValueF;
	 wire [2:0] funValueF;
	 wire [2:0] happyValueF;
	 wire [2:0] healthValueF;
	 wire [2:0] testValueF;
	 
	 wire feeding; 
	 wire healing;
	 wire change;
	 wire testBut;
	 wire Rst;
	 
signal_drivers drivers (
	 .clk(clk),
    .rst(rst),
	 //.light_out(light_out),
    //.echo_sig(echo_sig),
    .test_mode(test_mode), 
    .button_food(button_food),
    .button_heal(button_heal),
	 .change_butt(change_butt),
	 .feeding(feeding), 
	 .healing(healing),
	 .change(change),
	 .testBut(testBut),
	 .Rst(Rst)
);
	 
display displayOut(
	 .clk(clk), 
	 .rst(Rst),
	 .sseg(sseg7), 
	 .an(an_1), 
	 .an1(an1_1), 
	 .led(Led),
	 .foodValue(foodValueF),
	 .sleepValue(sleepValueF),
	 .funValue(funValueF),
	 .happyValue(happyValueF),
	 .healthValue(healthValueF),
	 .testValue(testValueF),
	 );

fsm_states states(
	.clk(clk), 
	.rst(Rst),
	.feeding1(feeding),
    .light_out1(light_out),
    .echo_sig1(echo_sig),
    .healing1(healing),
	 .change_state1(change),
	 .test1(testBut),
	.foodValue(foodValueF),
    .sleepValue(sleepValueF),
    .funValue(funValueF),
    .happyValue(happyValueF),
    .healthValue(healthValueF),
	 .stateTest(testValueF),	 
	);
endmodule