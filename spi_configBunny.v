/*
Este modulo configura y controla las variables que seran enviadas al spi_ master

ENTRADAS DESDE FPGA
			      ______________
			     |              |-----> HACIA PANTALLA
(de la fpga, pin) clock	-----|              |----> sclk
   	  (boton) Reset -----|   ________   |---->rst
                   	     |  | MASTER |  |---->mosi
		   	     |  |________|  |---->sce
       		   	     |              |---->dc
	      		     |______________|---->back 
			
*/


module spi_configBunny(
   input clock,
	input Reset,
	//input [3:0] draw,
	output mosi,
	output sclk,
	output sce,
	output dc,
	output rst,
	output reg back
	);
	
	reg [7:0] message; //mensaje o comando a enviar 
	reg spistart; 
	reg comm; //para DC (data/ command) 
	reg [7:0] poss_x; //posicion en x
	reg [7:0] poss_y; //posicion en y

	wire [15:0]freq_div;
	wire busy;
	wire avail;
	
	reg [4:0] state;
	reg [6:0] count=4'h0;
	
	parameter INIT=4'h0, CLEAN=4'h1, PERA=4'h2, NUBE=4'h3, CORAZON=4'h4, GAME=4'h5, 
	FELIZ=4'h6, BUNNY=4'h7;

	parameter BAR=4'h0;
	
	reg [8:0] i=0;
	reg [8:0] j=0;
	assign freq_div=25000000;// 1Hz(max 4MHz)
	
	reg[3:0] comida; //cambiar por una entrada 
	reg[3:0] food;

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
	back<=1;		
	
	case(state) 
		INIT:begin //configuracion inicial
			case(count)
			4'h0:begin  spistart<=1; comm<=0; if (avail) count<=4'h1; end
				
			4'h1: begin message<=8'b00100001;if (avail) count<=4'h2; end
			
			4'h2:begin  message<=8'b10010000; if (avail) count<=4'h3; end
			 
			4'h3: begin message<=8'b00100000; if(avail) count<=4'h4; end
			
			4'h4: begin message<=8'b00001100; if(avail) begin count<=4'h5; state<=4'h1; end end
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
					state<=4'h2;
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
		back<=0;
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
					state<=4'h3;
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
						state<=4'h4;
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
		back<=0;
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
				
				4'h5: begin  message<=8'b10000010; if(avail) 
				begin 
				i<=i+1;
				count<=4'h4;
			end
			end
			
		endcase	
		end
		
		GAME: begin
			case(count)
				4'h0: begin  comm<=0; poss_x<=8'h8D; message<=poss_x; if(avail) count<=4'h1;end 
				4'h1: begin   poss_y<=8'h41; message<=poss_y; if(avail) count<=4'h2;end
				
				4'h2: begin  comm<=1; message<=8'b11100000; 
					if(avail) begin
						if(i<2) count<=4'h3; 
						else begin
							state<=4'h6;
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
				4'h0: begin  comm<=0; poss_x<=8'hA6; message<=poss_x; if(avail) count<=4'h1;end
				
				4'h1: begin  comm<=1; message<=8'b00010000; 
					if(avail)begin
						if(i<2) count<=4'h2; 
						else begin
							state<=4'h7;
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
			poss_x<=8'hA5;
			poss_y<=8'h43;
			back<=0;	
			
			case(count)
		
			4'h0: begin  comm<=0; message<=poss_x; if(avail) count<=4'h1;end //posicion inical 
			4'h1: begin  message<=poss_y; if(avail) count<=4'h2; end
			
			4'h2: begin comm<=1; message<=8'b11111110; 
			if(avail) begin
				if(i<1) count<=4'h3;
				else begin
					count<=4'h7;
				end
				
			end
			end
			
			4'h3: begin  message<=8'b001000001;
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

			4'h7: begin comm<=0; poss_x<=8'hB2; message<=poss_x; i<=0; if(avail) count<=4'h8; end
			
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
			
				4'hA: begin comm<=0; poss_x<=8'hA5; message<=poss_x; if(avail) count<=4'hB; end
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
			6'h1A: begin  message<=8'b00000011; if(avail) spistart<=0; end
				
			endcase 
		end
		
	endcase
/*
		case(draw) 
			BAR: begin
			count<=4'h0;
				j<=5;// seria entrada segun nivel 
			case(count)
				4'h0: begin  spistart<=1; comm<=0; poss_x<=4'h89; message<=poss_x; if(avail) count<=4'h1;end 
				4'h1: begin   poss_y<=8'h40; message<=poss_y; if(avail) count<=4'h2;end

				4'h2: begin  comm<=1; message<=8'b01111110; 
					if(avail) begin 
						i<=i+1;
						if(i==1) count<=4'h2;
						else count<=4'h3;
						end
					end
				4'h3: begin  message<=8'h0; 
					if(avail) begin 
					end
						if(j>=0) begin
							j<=j-1;
							i<=0;
							count<=4'h2;
						end
						else spistart<=0;
					end
					
			endcase
			end
			
		endcase*/
	
	end
	
	 
endmodule
	 
