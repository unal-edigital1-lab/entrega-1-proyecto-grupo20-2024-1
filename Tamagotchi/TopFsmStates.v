`timescale 1ns / 1ps

module TopFsmStates(
    input Clk,
    input Rst1,
	input feeding,
    input light_out,
    input echo_sig,
    input healing,
	input change,
	input testBut,
	output trig_sig,
	output [0:6] sseg7,
	output [2:0] an_1,
	output [2:0] an1_1,
	output mosi,
	output sclk,
	output sce,
	output dc,
	output Reset,
	output reg back
    );

//CONEXION MAQUINA DE ESTADOS CON SALIDAS
	wire [2:0] foodValueF;
	wire [2:0] sleepValueF;
	wire [2:0] funValueF;
	wire [2:0] happyValueF;
	wire [2:0] healthValueF;
	wire [2:0] testValueF;

//CONEXION ENTRADAS CON SALIDAS
   wire feeding1;
	wire healing1;
	wire change1;
	wire light_out1;
	wire test_sig1;
	wire objectUltra1;
	wire rst;
	wire done;
	wire [3:0] face;

//DRIVER DE BOTONES
signal_drivers drivers(
	.clk(Clk),
    .rst1(Rst1),
	.light_out(light_out),
    .echo_sig(echo_sig),
    .test(testBut), 
    .button_food(feeding),
    .button_heal(healing),
	.button_change(change),
	.Rst(rst),
	.feeding(feeding1), 
	.healing(healing1),
	.change(change1),
	.trig_sig(trig_sig),
	.objectUltra(objectUltra1),
	.light(light_out1),
	.test_sig(test_sig1),
);

//MAQUINA DE ESTADOS
fsm_states states(
	.clk(Clk), 
	.rst1(rst),
	.feeding(feeding1),
    .light_out(light_out1),
    .echo_sig(objectUltra1),
    .healing(healing1),
	.change_state(change1),
	.test(test_sig1),
	.done(done),
	.feed_direct1(feeding),
	.heal_direct1(healing),
	.light_direct1(light_out),
	.echo_direct1(echo_sig),
	.trig_direct1(trig_sig),
	.test_direct1(testBut),
	.face1(face),
	.foodValue(foodValueF),
    .sleepValue(sleepValueF),
    .funValue(funValueF),
    .happyValue(happyValueF),
    .healthValue(healthValueF),
	.stateTest(testValueF),
	);

// SE utiliza reset dirctamente de la fpga por que no funciona bien
// PANTALLA NOKIA
spi_configBunny Configbunny(
    .clock(Clk),
    .Reset1(Rst1),
    .mosi(mosi),
    .sclk(sclk),
    .sce(sce),
    .dc(dc),
    .rst(Reset),
    .nivel_hambre(foodValueF),
	.nivel_sueno(sleepValueF), 
	.nivel_diversion(funValueF), 
	.nivel_animo(happyValueF), 
	.nivel_salud(healthValueF), 	
    .draw(face),
    .done(done),
  );

// DISPLAY 7 SEGMENTOS
display displayOut(
	 .clk(Clk), 
	 .rst(rst),
	 .sseg(sseg7), 
	 .an(an_1), 
	 .an1(an1_1),
	 .foodValue(foodValueF),
	 .sleepValue(sleepValueF),
	 .funValue(funValueF),
	 .happyValue(happyValueF),
	 .healthValue(healthValueF),
	 .testValue(testValueF),
	 );	
	
endmodule