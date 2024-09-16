`timescale 1ns / 1ps

module Buttons_driver(
    input rst,
    input test_mode, 
    input button_food,
    input button_heal,
    input clk,
    //Asignacion a leds
    output reg food_signal,
    output reg heal_signal,
    output reg reset,
    output reg test_signal
);
    
	wire food;
   wire heal;
   wire test;
   wire rst1;

    //Llamamos al antirrebote y archivo rst, test
    pb_rst reseteo(.pb_in1(rst), .clk(clk), .rst_signal(rst1));
    pb_rst modoTest(.pb_in1(test_mode), .clk(clk), .rst_signal(test));
    debounce antirrebo(.pb(button_food), .clk(clk), .out1(food));
    debounce antirrebote(.pb(button_heal), .clk(clk), .out1(heal));
    
	 initial begin 
	     heal_signal = 1;
        food_signal = 1;
        test_signal = 1;
        reset = 1;
	 end

    // Mirar que mas agregar
    always @(posedge clk) begin
        food_signal = ~food;
        heal_signal = ~heal;
        test_signal = ~test;
        reset = ~rst1;
    end

endmodule




