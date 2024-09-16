`timescale 1ns / 1ps

module signal_drivers(
	 input clk,
    input rst,
	 //input light_out,
    //input echo_sig,
    input test_mode, 
    input button_food,
    input button_heal,
	 input change_butt,
	 output feeding, 
	 output healing,
	 output change,
	 output testBut,
	 output Rst
	 //  output echo, 
	 //  output light
);

	 pb_rst reseteo(.pb_in1(rst), .clk(clk), .rst_signal(Rst));
    pb_rst modoTest(.pb_in1(test_mode), .clk(clk), .rst_signal(testBut));
    debounce antiReFeed(.pb(button_food), .clk(clk), .out1(feeding));
    debounce antiReHeal(.pb(button_heal), .clk(clk), .out1(healing));
    debounce antiReChange(.pb(change_butt), .clk(clk), .out1(change));
	 
	 
endmodule 
	