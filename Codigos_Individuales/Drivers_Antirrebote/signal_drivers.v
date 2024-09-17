`timescale 1ns / 1ps

module signal_drivers(
	input clk,
   input rst,
    input button_food,
    input button_heal,
	input button_change,
	//input light_out,
    //input echo_sig,
   input test, 
	output Rst,
	output feeding,
	output healing,
	output change,
	 //  output echo, 
	 //  output light
	 output test_sig
);
//BOTONES FPGA NEGADOS
assign button_food1 = ~button_food;
assign button_heal1 = ~button_heal;
assign test1 = ~test;
assign Rst = rst;

	 //pb_rst reseteo(.pb_in1(rst), .clk(clk), .rst_signal(Rst));
    pb_rst modoTest(.pb_in1(test1), .clk(clk), .rst_signal(test_sig));
    debounce antiReFeed(.pb(button_food1), .clk(clk), .out1(feeding));
    debounce antiReHeal(.pb(button_heal1), .clk(clk), .out1(healing));
    debounce antiReChange(.pb(button_change), .clk(clk), .out1(change));
	 
	 
endmodule 
	