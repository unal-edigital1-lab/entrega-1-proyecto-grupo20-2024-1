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

wire object1;
wire day_night;

    // sensores
	photoSensor photo(.clk(clk), .ldr_input(light_out), .day_night(day_night));
	ultrasound ultra(.clk(clk), .echo(echo_sig), .trigger(trig_sig), .object_detected(object1));

    // mantener presionados botones
	pb_tpressed reseteo(.pb_in(rst1), .clk(clk), .signal_out(Rst));
    pb_tpressed modoTest(.pb_in(test1), .clk(clk), .signal_out(test_sig));
	pb_tpressed lightness(.pb_in(day_night), .clk(clk), .signal_out(light));
	pb_tpressed echosignal(.pb_in(object1), .clk(clk), .signal_out(objectUltra));

	// antirrebotes
    debounce antiReFeed(.pb(button_food1), .clk(clk), .out1(feeding));
    debounce antiReHeal(.pb(button_heal1), .clk(clk), .out1(healing));
    debounce antiReChange(.pb(button_change), .clk(clk), .out1(change));
	 
	 
endmodule 
	