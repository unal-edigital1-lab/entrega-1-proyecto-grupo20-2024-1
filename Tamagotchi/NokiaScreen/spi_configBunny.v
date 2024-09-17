/*
Este modulo configura y controla las variables que seran enviadas al spi_ master

ENTRADAS DESDE FPGA
										______________
									   |              |-----> HACIA PANTALLA
        (de la fpga, pin) clock	  -----|              |----> sclk
			        (boton) Reset -----|   ________   |---->rst
                   	                   |  | MASTER |  |---->mosi
		   	                           |  |________|  |---->sce
       		   	                       |              |---->dc
	      		                       |______________|---->back 
			
*/


module spi_configBunny(
	input clock,//entradas y salidas fisicas con la tarjeta
	input Reset1,
	output mosi, 
	output sclk,
	output sce,
	output dc,
	output rst,
	
	//comunicacion core 
	input [3:0] nivel_hambre, 
	input [3:0] nivel_sueno, 
	input [3:0] nivel_diversion, 
	input [3:0] nivel_animo, 
	input [3:0] nivel_salud, 	
	input [3:0] draw,
	output reg done
	);

assign Reset = Reset1;

	reg [7:0] message; //mensaje o comando a enviar 
	reg spistart; 
	reg comm; //para DC (data/ command) 
	reg [7:0] poss_x; //posicion en x
	reg [7:0] poss_y; //posicion en y

	wire [15:0]freq_div;
	wire busy;
	wire avail;
	
	reg [4:0] state=4'h0;
	reg [6:0] count=4'h0;
	reg [3:0] sketch=4'h0;

	
	parameter INIT=4'h0, CLEAN=4'h1, PERA=4'h2, NUBE=4'h3, CORAZON=4'h4, GAME=4'h5, 
	FELIZ=4'h6, BUNNY=4'h7;

	parameter START=4'h0, BARS=4'h1, CARROT=4'h2, CRUZ=4'h3, SLEEPY=4'h4, STAR=4'h5, PART_CLEAN=4'h6, 
			TEST=4'h7, FACE_HAPPY=4'h8, FACE_NEUTRAL=4'h9, FACE_SAD=4'hA, FACE_DEAD=4'hB, STAND_BY=4'hC;

	
	reg [8:0] i=0;
	reg [8:0] j=0;
	reg [8:0] k=0;
	//reg [8:0] nivel_hambre;
	reg [3:0] nivel;
	assign freq_div=2500000;//25;(max 4MHz, min div 8)
	

	spi_master Spi_Master (
		.clk(clock),
		.reset(~Reset),
		.data_in(message),
		.start(spistart),
		.div_factor(freq_div),
		.command(comm),
		.mosi(mosi),
		.sclk(sclk),
		.sce (sce),
		.busy(busy),
		.avail(avail),
		.dc(dc),
		.rst(rst)
	);
 
 
	always @(posedge clock) begin
	
		message<=0;
		case(sketch)
		
		START:begin
			case(state) 
			INIT:begin //configuracion inicial
				done<=0;
				case(count) 
				4'h0:begin  spistart<=1; comm<=0; if (avail) count<=4'h1; end
					
				4'h1: begin message<=8'b00100001;if (avail) count<=4'h2; end
				
				4'h2:begin  message<=8'b10010000; if (avail) count<=4'h3; end
				 
				4'h3: begin message<=8'b00100000; if(avail) count<=4'h4; end
				
				4'h4: begin message<=8'b00001100; if(avail) begin count<=4'h5; state<=CLEAN; end end
				endcase
			end

			CLEAN: begin //limpia la pantalla
				case(count)
				4'h5: begin comm<=1; message<=8'h0; 
					if(avail) begin 
						if (i<=510) begin 
							i<=i+1;
							count<=4'h5;
						end 
						else 
						begin 
							state<=PERA;
							count<=4'h0;
							i<=0;
						end
					end
				end			
				endcase
			end

			 /* Hambriento: pera
			 Descanso: nube 
			 Salud: corazon
			 Diversión: lever
			 Feliz: =) */
				
			PERA: begin 
				poss_x<=8'h80;
				poss_y<=8'h40;

				case(count)
			
				4'h0: begin  comm<=0; message<=poss_x; if(avail) count<=4'h1;end //posicion inical 
				4'h1: begin  message<=poss_y; if(avail) count<=4'h2; end
				
				4'h2: begin  comm<=1; message<=8'b00110000; if(avail) count<=4'h3; end
				4'h3: begin  message<=8'b01001000; if(avail) count<=4'h4; end
				4'h4: begin  message<=8'b10000100; if(avail) count<=4'h5; end
				4'h5: begin  message<=8'b10000010; if(avail) count<=4'h6; end
				4'h6: begin  message<=8'b10000111; if(avail) count<=4'h7; end
				4'h7: begin  message<=8'b01001001; if(avail) count<=4'h8; end
				4'h8: begin  message<=8'b00110000; 
					if(avail) begin
						state<=NUBE;
						count<=4'h0;
					end
				end
				endcase	
			end
			
			NUBE: begin
				case(count)
				4'h0: begin  comm<=0; poss_x<=8'h9B; message<=poss_x; if(avail) count<=4'h1;end 
			
				4'h1: begin  comm<=1; message<=8'b00011000;
					if(avail) begin 
						if (i<4) count<=4'h2;
						else begin 
							state<=CORAZON;
							count<=4'h0;
							i<=0;
						end
					end
				end

				4'h2: begin  message<=8'b00100100; 
					if(avail) begin 
						if (i<4) count<=4'h3;
						else count<=4'h1;
					end
				end
				4'h3: begin  message<=8'b01000010; 
					if(avail) begin
						i<=i+1;
						if (i==0) count<=4'h3;
						else if (i<4) count<=4'h4;
						else count<=4'h2;
					end
				end
				
				
				4'h4: begin  message<=8'b01000001; 
					if(avail) begin 
						i<=i+1;
						if (i<=4) count<= 4'h4;
						else count<=4'h3; 
					end
				end
				endcase	
			end

			CORAZON: begin
				case(count)
				4'h0: begin  comm<=0; poss_x<=8'hB8; message<=poss_x; if(avail) count<=4'h1;end 
			
				4'h1: begin comm<=1; message<=8'b00001100; 
					if(avail) begin
						if(i>0) begin
							state<=GAME;
							count<=4'h0;
							i<=0;
						end							
						else count<=4'h2; 
					end
				end
				
				4'h2: begin  message<=8'b00010010; 
					if(avail) begin
						if(i>0) count<=4'h1;
						else count<=4'h3; 
					end
				end
				
				4'h3: begin  message<=8'b00100001; 
					if(avail) begin
						if(i>0) count<=4'h2;
						else  count<=4'h4;
					end
				end
				
				4'h4: begin  message<=8'b01000001; 
					if(avail) begin 
						if(i>0) count<=4'h3;
						else count<=4'h5; 
					end 
				end
				
				4'h5: begin  message<=8'b10000010; 
					if(avail) begin 
						i<=i+1;
						count<=4'h4;
					end
				end

				endcase	
			end
			
			GAME: begin
				case(count)
				4'h0: begin  spistart<=1; comm<=0; poss_x<=8'h8D; message<=poss_x; if(avail) count<=4'h1;end 
				4'h1: begin   poss_y<=8'h41; message<=poss_y; if(avail) count<=4'h2;end
				
				4'h2: begin  comm<=1; message<=8'b11100000; 
					if(avail) begin
						if(i<2) count<=4'h3; 
						else begin
							state<=FELIZ;
							count<=4'h0;
							i<=0;
						end
					end
				end
				4'h3: begin  message<=8'b10100000; 
					if(avail) begin 
						if(i<2) count<=4'h4; 
						else count<=4'h2;
					end
				end
				4'h4: begin  message<=8'b10100011;
					if(avail)begin
						i<=i+1;
						if(i==0) count<=4'h5; 
						else count<=4'h3;
					end
				end
				4'h5: begin  message<=8'b10111111; if(avail) count<=4'h4; end
				
				endcase	
			end

			FELIZ: begin
				case(count)
				4'h0: begin  comm<=0; poss_x<=8'hB3; message<=poss_x; if(avail) count<=4'h1;end
				
				4'h1: begin  comm<=1; message<=8'b00010000; 
					if(avail)begin
						if(i<2) count<=4'h2; 
						else begin
							state<=BUNNY;
							count<=4'h0;
							i<=0;
						end
					end
				end
				4'h2: begin  message<=8'b00100000; 
					if(avail) begin 
						if(i<2) count<=4'h3; 
						else count<=4'h1;
					end
				end
				4'h3: begin  message<=8'b01000111; 
					if(avail) begin 
						if(i<2) count<=4'h4; 
						else count<=4'h2;
					end
				end
				4'h4: begin  message<=8'b01000000; 
					if(avail) begin 
						i<=i+1;
						if (i==0) count<=4'h4;
						else count<=4'h3;
					end
				end
				
				endcase	
			end

			
			BUNNY: begin //dibujar
				poss_x<=8'hA2;
				poss_y<=8'h43;
				
				case(count)
				4'h0: begin done<=0; spistart<=1; comm<=0; message<=poss_x; if(avail) count<=4'h1;end //posicion inical 
				4'h1: begin  message<=poss_y; if(avail) count<=4'h2; end
				
				4'h2: begin comm<=1; message<=8'b11111110; 
					if(avail) begin
						if(i<1) count<=4'h3;
						else count<=4'h7;
					end
				end
				
				4'h3: begin  message<=8'b00100001;
						if(avail) begin 
						if(i<1) count<=4'h4;
						else count<=4'h2;	
					end
				end
				
				4'h4: begin message<=8'b00010001; 
					if(avail) begin 
						if(i<1) count<=4'h5;
						else count<=4'h3;	
					end
				end
				
				4'h5: begin message<=8'b00011110; 
					if(avail) begin 
						if(i<1) count<=4'h6;
						else count<=4'h4;				
					end
				end	

				4'h6: begin message<=8'b00001000; 
					if(avail) begin 
						i<=i+1;
						if (i==0) count<=4'h6;
						else count<=4'h5;
					end
				end

				4'h7: begin comm<=0; poss_x<=8'hAF; message<=poss_x; i<=0; if(avail) count<=4'h8; end
				
				4'h8: begin comm<=1; message<=8'b10000000; 
					if(avail) begin
						i<=i+1;
						if(i==0) count<=4'h9; 
						else begin 
							i<=0;
							count<=4'hA;
						end
					end
				end
					
				4'h9: begin message<=8'b01000000; 
					if(avail) begin
						i<=i+1;
						if(i==1) count<=4'h9; 
						else count<=4'h8;
					end
				end
				
				//-----segundo renglon
				
				4'hA: begin comm<=0; poss_x<=8'hA2; message<=poss_x; if(avail) count<=4'hB; end
				4'hB: begin poss_y<=poss_y-1; message<=poss_y; if(avail) count<=4'hC; end

				4'hC: begin comm<=1; message<=8'b00000111;  if(avail) count<=4'hD; end
				4'hD: begin message<=8'b00001100; if(avail) count<=4'hE; end
				4'hE: begin message<=8'b00011000; if(avail) count<=6'hF; end
				6'hF: begin message<=8'b00010011; if(avail) count<=6'h10; end
				6'h10: begin  message<=8'b00010000; if(avail) count<=6'h11; end
				6'h11: begin  message<=8'b00110000; if(avail) count<=6'h12; end
				6'h12: begin  message<=8'b01010011; if(avail) count<=6'h13; end

				6'h13: begin  message<=8'b10000000;
						if(avail) begin 
						i<=i+1;
						if(i<1) count<=6'h13; 
						else count<=6'h14;	
					end
				end
			
				6'h14: begin  message<=8'b11100001; 
					if(avail) begin 
						if(i==2) count<=6'h15;
						else count<=6'h16;
					end
				end
					
				6'h15: begin  message<=8'b01000001; 
					if(avail) begin 
						i<=i+1;
						if(i==2) count<=6'h15; 
						else count<=6'h14;	
					end
				end

				6'h16: begin  message<=8'b10000011; if(avail) count<=6'h17; end
				6'h17: begin  message<=8'b10000110; if(avail) count<=6'h18; end
				6'h18: begin  message<=8'b01111100; if(avail) count<=6'h19; end
				6'h19: begin  message<=8'b00000100; if(avail) count<=6'h1A; end
				
				6'h1A: begin  message<=8'b00000011; 
					if(avail) begin  
						spistart<=0;
						done<=1;
						sketch<=STAND_BY;
					end
				end
					
				endcase 
			end

			endcase
		end
			
		STAND_BY: begin 
			count<=4'h0;
			if(sketch != draw) sketch<=draw;
		end 
		
					
		BARS: begin 
			done<=0;
			case(count)
			4'h0: begin  spistart<=1; i<=0; j<=0; nivel<=nivel_hambre; comm<=0; poss_x<=8'h89; message<=poss_x; if(avail) count<=4'h1; end 
			4'h1: begin   poss_y<=8'h40; message<=poss_y; if(avail) count<=4'h2; end

			4'h2: begin  comm<=1; message<=8'b01111110; 
				if(avail) begin 
					i<=i+1;
					k<=k+1;
					if(i==0) count<=4'h2;
					else count<=4'h3;
				end
			end

			4'h3: begin  message<=8'h0; 
				if(avail) begin 
					if(nivel>1) begin
						k<=k+1;
						nivel<=nivel-1;
						i<=0;
						count<=4'h2;
					end
					else count<=4'h4;
				end
			end
						
			4'h4: begin message<=8'h0; 
				if(avail) begin
					if(k<4'hD) begin
						k<=k+1;
						count<=4'h4;
					end
					else if (j==0) count<=4'h5; 
					else if (j==1) count<=4'h6;
					else if (j==2) count<=4'h7;
					else if (j==3) count<=4'h9;
					else begin 
						spistart<=0;
						done<=1;
						sketch<=STAND_BY;
					end
				end
			end
			4'h5: begin  nivel<=nivel_sueno; k<=0; i<=0; comm<=0; poss_x<=8'hA7; message<=poss_x; if(avail) begin j<=j+1; count<=4'h2; end end //cambiar por nivel sueño
			
			4'h6: begin  nivel<=nivel_salud; k<=0; i<=0; comm<=0; poss_x<=8'hC2; message<=poss_x; if(avail) begin j<=j+1; count<=4'h2; end end //cambiar por otro nivel

			4'h7: begin  nivel<=nivel_diversion; k<=0; comm<=0; poss_x<=8'h95; message<=poss_x; if(avail) begin j<=j+1; count<=4'h8; end end //cambiar por otro nivel
			4'h8: begin  comm<=0;  i<=0; poss_y<=8'h41; message<=poss_y; if(avail) count<=4'h2;end

			4'h9: begin  nivel<=nivel_animo; k<=0; i<=0; comm<=0; poss_x<=8'hBC; message<=poss_x; if(avail) begin j<=j+1; count<=4'h2; end end //cambiar por otro nivel
			
			endcase
		end

		CARROT: begin
			done<=0;
			case(count)
	        4'h0: begin  spistart<=1; i<=0; j<=0; comm<=0; poss_x<=8'h8E; message<=poss_x; if(avail) count<=4'h1;end 
			4'h1: begin   poss_y<=8'h43; message<=poss_y; if(avail) count<=4'h2; end
					
	        4'h2: begin  comm<=1; message<=8'b10000000; if(avail) count<=4'h3; end
	        4'h3: begin  message<=8'b11000000; if(avail) count<=4'h4; end
	        4'h4: begin  message<=8'b01000000; 
				if(avail) begin
					i<=i+1;
					if(i<1) count<=4'h4; 
					else count<=4'h5;
	         	end
			end
	
	        4'h5: begin  i<=0; message<=8'b01111000; if(avail) count<=4'h6; end
	        4'h6: begin  message<=8'b01001110; if(avail) count<=4'h7; end
			  4'h7: begin  comm<=1; message<=8'b11000010; if(avail) count<=4'h8; end
			  4'h8: begin  message<=8'b00111110; if(avail) count<=4'h9; end
				4'h9: begin  message<=8'b00100000; if(avail) count<=4'hA; end
	        4'hA: begin comm<=1; message<=8'b10100000; 
				if(avail) begin
					i<=i+1;
					if(i<3) count<=4'hA; 
					else count<=4'hB;
				end
			end
				
			4'hB: begin  message<=8'b11100000; if(avail) count<=4'hC; end

			//-----------------------
			
			4'hC: begin  comm<=0; poss_x<=8'h8A; message<=poss_x; if(avail) count<=4'hD;end 
			4'hD: begin   poss_y<=poss_y-1; message<=poss_y; if(avail) count<=4'hE; end

			4'hE: begin comm<=1; i<=0; message<=8'b11110000; if(avail) count<=4'hF; end
			4'hF: begin  message<=8'b10011000; if(avail) count<=6'h10; end
			6'h10: begin  message<=8'b10001110; if(avail) count<=6'h11; end
			6'h11: begin  message<=8'b10001011; if(avail) count<=6'h12; end
			6'h12: begin  message<=8'b11011001; if(avail) count<=6'h13; end
			6'h13: begin  message<=8'b01000000; if(avail) count<=6'h14; end
			6'h14: begin  message<=8'b01100000; if(avail) count<=6'h15; end
			6'h15: begin  comm<=1; message<=8'b00100000; if(avail) count<=6'h16; end
			6'h16: begin  message<=8'b00110110; if(avail) count<=6'h17; end
			6'h17: begin  message<=8'b00011100; if(avail) count<=6'h18; end
			6'h18: begin  message<=8'b00000111; if(avail) count<=6'h19; end
			6'h19: begin  comm<=1; message<=8'b00000001; 
				if(avail) begin
					i<=i+1;
					if(i<4) count<=6'h19; 
					else count<=6'h1A;
				end
			end
			
			6'h1A: begin 
				spistart<=0;
				done<=1;
				sketch<=STAND_BY;
			end
						
			endcase	
		end

		CRUZ: begin
			done<=0;
			case(count)
			4'h0: begin  spistart<=1; comm<=0; i<=0; j<=0; poss_x<=8'h9A; message<=poss_x; if(avail) count<=4'h1;end 
			4'h1: begin   poss_y<=8'h42; message<=poss_y; if(avail) count<=4'h2; end
			
			4'h2: begin  comm<=1; message<=8'b00111100;
				if(avail) begin
					if(i==0) count<=4'h3; 
					else begin
						spistart<=0;
						done<=1;
						sketch<=STAND_BY;
					end
				end
			end
			4'h3: begin  message<=8'b00100100; 
				if(avail) begin
					if(i==0) count<=4'h4; 
					else count<=4'h2;		
				end
			end
			4'h4: begin  message<=8'b11100111; 
				if(avail) begin
					if(i==0) count<=4'h5; 
					else count<=4'h3;		
				end
			end
			4'h5: begin  message<=8'b10000001; 
				if(avail) begin
					i<=i+1;
					if(i==0) count<=4'h5; 
					else count<=4'h4;		
				end
			end

			endcase
		end 

			
		SLEEPY: begin
			done<=0;
			case(count)
			4'h0: begin  spistart<=1; comm<=0;  i<=0; j<=0; poss_x<=8'hB1; message<=poss_x; if(avail) count<=4'h1;end 
			4'h1: begin   poss_y<=8'h42; message<=poss_y; if(avail) count<=4'h2; end
			
			4'h2: begin  comm<=1; message<=8'b11001000-i; 
				if(avail) begin
					j<=j+1;
					if(j==0) begin i<=8'h20; count<=4'h2; end
					else if(j==1) begin i<=8'h30; count<=4'h2; end
					else if(j==2) begin i<=8'h40; count<=4'h2; end
					else count<=4'h3;	
				end	
			end
			
			4'h3: begin i<=0; j<=0; message<=8'h0; if(avail) count<=4'h4; end
			
			4'h4: begin  comm<=1; message<=8'b01100100-i; 
				if(avail) begin
					j<=j+1;
					if(j==0) begin i<=8'h10; count<=4'h4; end
					else if(j==1) begin i<=8'h18; count<=4'h4; end
					else if(j==2) begin i<=8'h20; count<=4'h4; end
					else count<=4'h5;	
				end	
			end
			
			4'h5: begin i<=0; j<=0; message<=8'h0; if(avail) count<=4'h6; end
			
			4'h6: begin  comm<=1; message<=8'b00110010-i; 
				if(avail) begin
					j<=j+1;
					if(j==0) begin i<=8'h8; count<=4'h6; end
					else if(j==1) begin i<=8'hC; count<=4'h6; end
					else if(j==2) begin i<=8'h10; count<=4'h6; end
					else count<=4'h7;	
				end	
			end
			
			4'h7: begin 
				spistart<=0;
				done<=1;
				sketch<=STAND_BY;
			end
			
			endcase
		end

		STAR: begin
			done<=0;
			case(count)
			4'h0: begin  spistart<=1; comm<=0; j<=0; i<=0; poss_x<=8'hBC; message<=poss_x; if(avail) count<=4'h1;end 
			4'h1: begin   poss_y<=8'h43; message<=poss_y; if(avail) count<=4'h2; end
			4'h2: begin  comm<=1; message<=8'b01000000;
				if(avail) begin
					if (j==0) count<=4'h3;
					else count<=4'h8;
				end
			end
				
			4'h3: begin   message<=8'b10100000;
				if(avail) begin
					if (j==0) count<=4'h4;
					else count<=4'h2;
				end
			end

			4'h4: begin   message<=8'b00100000; 
				if(avail) begin
					i<=i+1;
					if(i<2) count<=4'h4;
					else if (j==0) count<=4'h5;
					else count<=4'h3;
				end
			end
			
			4'h5: begin   message<=8'b00011000;
				if(avail) begin
					if (j==0) count<=4'h6;
					else begin i<=0; count<=4'h4; end
				end
			end

			4'h6: begin   message<=8'b00000110; 
				if(avail) begin
					if (j==0) count<=4'h7;
					else count<=4'h5;
				end
			end
			
			4'h7: begin  comm<=1; message<=8'b00000001; 
				if(avail) begin
					j<=j+1;
					if (j==0) count<=4'h7;
					else count<=4'h6;
				end
			end
			
			//---------------------------------------
			
			4'h8: begin   comm<=0; i<=0; j<=0; poss_x<=8'hBD; message<=poss_x; if(avail) count<=4'h9;end 
			4'h9: begin   poss_y<=poss_y-1; message<=poss_y; if(avail) count<=4'hA; end
			
			4'hA: begin  comm<=1; message<=8'b11100000;
				if(avail) begin
					if (j==0) count<=4'hB;
					else begin
						done<=1;
						spistart<=0;
						sketch<=STAND_BY;
					end
				end
			end
				
			4'hB: begin   message<=8'b10011001;
				if(avail) begin
					if (j==0) count<=4'hC;
					else count<=4'hA;
				end
			end
					
			4'hC: begin   message<=8'b10000110;
				if(avail) begin
					if (j==0) count<=4'hD;
					else count<=4'hB;
				end
			end
			
			4'hD: begin   message<=8'b01000000; 
				if(avail) begin
					i<=i+1;
					if(i<2) count<=4'hD;
					else if (j==0) count<=4'hE;
					else count<=4'hC;
				end
			end
			
			4'hE: begin   message<=8'b00100000;
				if(avail) begin
					if (j==0) count<=4'hF;
					else begin i<=0; count<=4'hD; end
				end
			end
			
			4'hF: begin comm<=1; message<=8'b00010000;
				if(avail) begin
					j<=j+1;
					if (j==0) count<=4'hF;
					else begin i<=0; count<=4'hE; end
				end
			end

			endcase	
		end

		PART_CLEAN: begin //limpia alrededor del conejo
			done<=0;
			case(count)
			4'h0: begin  spistart<=1; comm<=0; i<=0; j<=0; poss_y<=8'h42; message<=poss_y; if(avail) count<=4'h1;end
			4'h1: begin   poss_x<=8'h94; message<=poss_x; if(avail) count<=4'h2;end 
			
			4'h2: begin comm<=1; message<=8'h0; 
				if(avail) begin 
					i<=i+1;
					if(i<50) count<=4'h2;
					else count<=4'h3;
				end
			end
			
			4'h3: begin comm<=0; i<=0; poss_y<=8'h43; message<=poss_y; if(avail) count<=4'h4;end
		
			4'h4: begin comm<=0; poss_x<=8'h80; message<=poss_x; if(avail) count<=4'h5;end
			
			4'h5: begin comm<=1; message<=8'h0; 
				if(avail) begin 
					if (i<26) begin 
						i<=i+1;
						count<=4'h5;
					end 
					else begin 
						j<=j+1;
						if (j==0) count<=4'h6; 
						else if (j==1) count<=4'h7;
						else if (j==2) count<=4'h6;
						else count<=4'h9;
					end
				end
			end
			
			4'h6: begin comm<=0; i<=0; poss_x<=8'hBA; message<=poss_x; if(avail) count<=4'h5; end
			
			4'h7: begin comm<=0; i<=0; poss_y<=poss_y-1; message<=poss_y; if(avail) count<=4'h8; end
			4'h8: begin comm<=0; i<=0; poss_x<=8'h80; message<=poss_x; if(avail) count<=4'h5; end
			
			4'h9: begin 
				done<=1;
				spistart<=0;
				sketch<=STAND_BY;
			end
				
			endcase
		end

		TEST: begin
			done<=0;
			case(count)
			4'h0: begin  spistart<=1; comm<=0; i<=0; j<=0;  poss_x<=8'h83; message<=poss_x; if(avail) count<=4'h1;end 
			4'h1: begin   poss_y<=8'h42; message<=poss_y; if(avail) count<=4'h2; end

			4'h2: begin comm<=1; message<=8'b00000100; if(avail) count<=4'h3; end
			4'h3: begin  message<=8'b00000100; if(avail) count<=4'h4; end
			4'h4: begin   message<=8'b01111100; if(avail) count<=4'h5; end
			4'h5: begin comm<=1; message<=8'b00000100; if(avail) count<=4'h6; end
			4'h6: begin  message<=8'b00000100; if(avail) count<=4'h7; end
			4'h7: begin 
				done<=1;
				spistart<=0;
				sketch<=STAND_BY;
			end
			endcase
		end

		FACE_HAPPY: begin
			done<=0;
			case(count)
			4'h0: begin spistart<=1; comm<=0; i<=0; j<=0; poss_x<=8'hA5; message<=poss_x; if(avail) count<=4'h9;end 
			4'h1: begin poss_y<=8'h43; message<=poss_y; if(avail) count<=4'h2; end

			4'h2: begin comm<=1; message<=8'b11011110;
				if(avail) begin
					if (i==0) count<=4'h3;
					else count<=4'h4;
				end
			end

			4'h3: begin  message<=8'b00001000;
				if(avail) begin
					i<=i+1;
					if (i==0) count<=4'h3;
					else count<=4'h2;
				end
			end

			4'h4: begin  comm<=0; poss_x<=8'hA5; message<=poss_x; if(avail) count<=4'h5;end  
			4'h5: begin  poss_y<=8'h44; message<=poss_y; if(avail) count<=4'h6; end

			4'h6: begin  comm<=1; message<=8'b00010010; if(avail) count<=4'h7; end
			4'h7: begin  message<=8'b00010100; if(avail) count<=4'h8; end
			4'h8: begin  message<=8'b00110100; if(avail) count<=4'h9; end
			4'h9: begin  message<=8'b01010010; if(avail) count<=4'hA; end

			4'hA: begin 
				done<=1;
				spistart<=0;
				sketch<=STAND_BY;
			end

			endcase
		end

		FACE_NEUTRAL: begin
			done<=0;
			case(count)
			4'h0: begin spistart<=1; comm<=0; i<=0; j<=0; poss_x<=8'hA5; message<=poss_x; if(avail) count<=4'h1;end 
			4'h1: begin poss_y<=8'h43; message<=poss_y; if(avail) count<=4'h2; end
			
			4'h2: begin comm<=1; message<=8'b11011110;
				if(avail) begin
					if (i==0) count<=4'h3;
					else count<=4'h4;
				end
			end

			4'h3: begin  message<=8'b00001000;
				if(avail) begin
					i<=i+1;
					if (i==0) count<=4'h3;
					else count<=4'h2;
				end
			end
		

			4'h4: begin  comm<=0; poss_x<=8'hA5; message<=poss_x; if(avail) count<=4'h5;end  
			4'h5: begin   poss_y<=8'h44; message<=poss_y; if(avail) count<=4'h6; end

			4'h6: begin comm<=1; message<=8'h0; if(avail) count<=4'h7; end
			4'h7: begin  message<=8'b00010010; if(avail) count<=4'h8; end
			4'h8: begin  message<=8'b00110010; if(avail) count<=4'h9; end
			4'h9: begin  message<=8'h0; if(avail) count<=4'hA; end

			4'hA: begin 
				done<=1;
				spistart<=0;
				sketch<=STAND_BY;
			end

			endcase
		end

		FACE_SAD: begin
			done<=0;
			case(count)
			4'h0: begin spistart<=1; comm<=0; i<=0; j<=0; poss_x<=8'hA5; message<=poss_x; if(avail) count<=4'h1;end 
			4'h1: begin   poss_y<=8'h43; message<=poss_y; if(avail) count<=4'h2; end
			
			4'h2: begin comm<=1; message<=8'b11011110;
				if(avail) begin
					if (i==0) count<=4'h3;
					else count<=4'h4;
				end
			end

			4'h3: begin  message<=8'b00001000;
				if(avail) begin
					i<=i+1;
					if (i==0) count<=4'h3;
					else count<=4'h2;
				end
			end
		

			4'h4: begin  comm<=0; poss_x<=8'hA5; message<=poss_x; if(avail) count<=4'h5;end  
			4'h5: begin   poss_y<=8'h44; message<=poss_y; if(avail) count<=4'h6; end

			4'h6: begin comm<=1; message<=8'b00010100; if(avail) count<=4'h7; end
			4'h7: begin  message<=8'b00010010; if(avail) count<=4'h8; end
			4'h8: begin  message<=8'b00110010; if(avail) count<=4'h9; end
			4'h9: begin  message<=8'b01010100; if(avail) count<=4'hA; end

			4'hA: begin 
				done<=1;
				spistart<=0;
				sketch<=STAND_BY;
			end

			endcase
		end

		FACE_DEAD: begin
			done<=0;
			case(count)
			4'h0: begin spistart<=1; comm<=0; i<=0; j<=0; poss_x<=8'hA4; message<=poss_x; if(avail) count<=4'h1;end 
        	4'h1: begin   poss_y<=8'h43; message<=poss_y; if(avail) count<=4'h2; end
		
			4'h2: begin comm<=1; message<=8'b10010001;
				if(avail) begin
					if (i==0) count<=4'h3;
					else count<=4'h5;
				end
			end

			4'h3: begin  message<=8'b10011110;
				if(avail) begin
					if (i==0) count<=4'h4;
					else count<=4'h2;
				end
			end

			4'h4: begin  message<=8'b00001000;
				if(avail) begin
					i<=i+1;
					if (i==0) count<=4'h4;
					else count<=4'h3;
				end
			end
			

			4'h5: begin  comm<=0; poss_x<=8'hA5; message<=poss_x; if(avail) count<=4'h6;end  
			4'h6: begin   poss_y<=8'h44; message<=poss_y; if(avail) count<=4'h7; end

			4'h7: begin comm<=1; message<=8'b00010100; if(avail) count<=4'h8; end
			4'h8: begin  message<=8'b00010010; if(avail) count<=4'h9; end
			4'h9: begin  message<=8'b00110010; if(avail) count<=4'hA; end
			4'hA: begin  message<=8'b01010100; if(avail) count<=4'hB; end

			4'hB: begin 
				done<=1;
				spistart<=0;
				sketch<=STAND_BY;
			end

			endcase
		end

		endcase
	end
endmodule
	 
