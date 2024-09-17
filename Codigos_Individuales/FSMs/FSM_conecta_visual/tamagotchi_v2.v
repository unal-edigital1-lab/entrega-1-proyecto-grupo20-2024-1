
module tamagotchi_v2(
	input Clk,
	input Rst,
	input feeding,
	input light_out,
	input echo_sig,
	input healing,
	input change,
	input testBut,
	output [0:6] sseg7,
	output [2:0] an_1,
	output [2:0] an1_1,
	output Led,
	output mosi,
	output sclk,
	output sce,
	output dc,
	output rst,
	output reg back
	);
 


	 wire [2:0] foodValueF;
	 wire [2:0] sleepValueF;
	 wire [2:0] funValueF;
	 wire [2:0] happyValueF;
	 wire [2:0] healthValueF;
	 wire [2:0] testValueF;
	 
	 wire done;
	wire [3:0] face;
	  
display displayOut(
	 .clk(Clk), 
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
	 .testValue(testValueF)
	 );

fsm_states states(
	.clk(Clk), 
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
	.face1(face),
	.done(done),
	.sclock(sclk)
	);
	
	spi_configBunny Configbunny(
    .clock(Clk),
    .Reset(Rst),
    .mosi(mosi),
    .sclk(sclk),
    .sce(sce),
    .dc(dc),
    .rst(rst),
    .nivel_hambre(foodValueF),
	 .nivel_sueno(sleepValueF), 
	.nivel_diversion(funValueF), 
	.nivel_animo(happyValueF), 
	.nivel_salud(healthValueF), 	
    .draw(face),
    .done(done)
  );
endmodule



