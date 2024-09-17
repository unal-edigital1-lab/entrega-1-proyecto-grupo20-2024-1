`timescale 1ns / 1ps

module signal_drivers(
	input clk,
    input rst1,
    input button_food,
    input button_heal,
	input button_change,
	input light_out,
    input echo_sig,
    input test, 
	output Rst,
	output feeding,
	output healing,
	output change,
	 //  output echo, 
	output light,
	output trig_sig,
	output objectUltra,
	output test_sig
);
//BOTONES FPGA NEGADOS
assign button_food1 = ~button_food;
assign button_heal1 = ~button_heal;
assign test1 = ~test;
//assign rst2 = rst1;
assign Rst = rst1;

wire object1;
wire day_night;

   // sensores
	photoSensor photo(.clk(clk), .ldr_input(light_out), .day_night(day_night));
	ultrasound ultra(.clk(clk), .echo(echo_sig), .trigger(trig_sig), .object_detected(object1));

    // mantener presionados botones
	 //pb_rst reseteo(.pb_in1(rst2), .clk(clk), .rst_signal(Rst));
    pb_rst modoTest(.pb_in1(test1), .clk(clk), .rst_signal(test_sig));
	 pb_rst lightness(.pb_in1(day_night), .clk(clk), .rst_signal(light));
	 pb_rst echosignal(.pb_in1(object1), .clk(clk), .rst_signal(objectUltra));

	
	// antirrebotes
    debounce antiReFeed(.pb(button_food1), .clk(clk), .out1(feeding));
    debounce antiReHeal(.pb(button_heal1), .clk(clk), .out1(healing));
    debounce antiReChange(.pb(button_change), .clk(clk), .out1(change));
	//debounce antiLight(.pb(day_night), .clk(clk), .out1(light));
	//debounce antiEcho(.pb(object1), .clk(clk), .out1(objectUltra));
	 
	 
endmodule 
	