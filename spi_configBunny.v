/*
Este modulo configura y controla las variables que seran enviadas al spi_ master

ENTRADAS DESDE FPGA
										_______________
									  |               |
(de la fpga, pin)	clock	-----|               |----> clk
(boton)				Reset	-----|               |---->rst
									  |       message |----> data_in[7:0] 
									  |       spistart|----> start 
									  |       freq    |----> freq_div[15:0]  
									  |     		      |---- > data_out [7:0](se pone por coherencia pero no sirve xd)
							        |               |---- > busy
									  |               |---- >avail
									  |_______comm____|----> command


*/


module spi_configBunny(
   input clock,
	input Reset,
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
	
	reg [4:0] state=4'h0;
	reg [4:0] count=4'h0;
	
	parameter INIT=4'h0, CLEAN=4'h1, BUNNY=4'h2;
	
	reg [8:0] i=0;
	reg [7:0] j=0;
	assign freq_div=25000000;// 1Hz(max 4MHz)
	

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
			
			4'h4: begin message<=8'b00001100; if(avail) begin count<=4'h0; state<=4'h1; end end
			endcase
		end

		CLEAN: begin //limpia la pantalla
			case(count)
			4'h0: begin comm<=1; message<=8'h0; 
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
		
		BUNNY: begin //dibujar
			poss_x<=8'hA1;
			poss_y<=8'h42;
			back<=0;	
			case(count)
		
			4'h0: begin  comm<=0; message<=poss_x; if(avail) count<=4'h1;end //posicion inical 
			4'h1: begin  message<=poss_y; if(avail) count<=4'h2; end
			
			4'h2: begin comm<=1; message<=8'b11111110; //primer renglon
			if(avail) begin
				if(j==1) count<= 4'h6;
				else count<=4'h3;
			end
			end
			
			4'h3: begin  message<=8'b10000001;
         		if(avail) begin 
				i<=i+1;
				if(i==0) count<=4'h3;
				else if(j==1) count<= 4'h2;
				else count<=4'h4;	
			end
			end
			
			4'h4: begin message<=8'b01111110; 
			if(avail) begin 
				if(i==4) begin j<=1; i<=0; count<=4'h3; end
				else count<=4'h5;	
			end
			end
			
			4'h5: begin message<=8'b00100000; 
			if(avail) begin 
				i<=i+1;
				if(i==2) count<=4'h5; 
				else count<=4'h4;
			end
			end	
			 
		
			//-----segundo renglon
			
			4'h6: begin comm<=0; poss_x<=8'hA1; message<=poss_x; if(avail) count<=4'h7; end
			4'h7: begin poss_y<=poss_y-1; message<=poss_y; if(avail) count<=4'h8; end
			4'h8: begin comm<=1; message<=8'b00111111; i<=0; j<=0; if(avail) count<=4'h9; end
			4'h9: begin message<=8'b01100000; if(avail) count<=4'hA; end
			4'hA: begin message<=8'b11000000; if(avail) count<=6'hB; end
			
			6'hB: begin message<=8'b10001110; 
			if(avail) begin
				if(i==2) count<=6'hD;
				else count<=6'hC;
			end
			end


			6'hC: begin  message<=8'b10000000;
         	if(avail) begin 
				i<=i+1;
				if(i==0) count<=6'hC;
				else count<=6'hB;	
			end
			end

			6'hD: begin comm<=0; poss_x<= poss_x-9; message<=poss_x; if(avail) count<=6'hE; end
			6'hE: begin comm<=1;  message<=8'b00001111; i<=0; if(avail) count<=6'hF; end

			6'hF: begin  message<=8'b00001000;
         	if(avail) begin 
				i<=i+1;
				if(i<2) count<=6'hF; 
				else count<=6'h10;	
			end
			end
		
		
			6'h10: begin  message<=8'b00011100; if(avail) count<=6'h11; end
			6'h11: begin  message<=8'b00110010; if(avail) count<=6'h12; end
			6'h12: begin  message<=8'b11100010; if(avail) count<=6'h13; end
			6'h13: begin  message<=8'b00100100; if(avail) count<=6'h14; end
			6'h14: begin  message<=8'b00011000; if(avail) count<=6'h15; end

			//------tercer renglon
			
			6'h15: begin comm<=0; poss_x<=8'hA5; message<=poss_x;  if(avail) count<=6'h16; end
			6'h16: begin poss_y<=poss_y-2; message<=poss_y; if(avail) count<=6'h17;end
			6'h17: begin comm<=1; message<=8'b00000001; if(avail) count<=6'h18; end
			6'h18: begin  message<=8'b00000011; if(avail) count<=6'h19; end
			6'h19: begin  message<=8'b00000110;i<=0; j<=0; if(avail) count<=6'h1A; end
			
			6'h1A: begin message<=8'b00001000; 
			if(avail) begin
				i<=i+1;
				if(i==0) count<= 6'h1A;
				else if(j==1) count<=6'h1D;
				else count<=6'h1B;
			end
			end
			
			6'h1B: begin  message<=8'b00001110; 
         	if(avail) begin 
				if(j==1) begin i<=0; count<=6'h1A; end
				else count<=6'h1C;	
			end
			end
			
			6'h1C: begin message<=8'b00000100; 
			if(avail) begin 
				j<=1;
				i<=i+1;
				if(i==2) count<=6'h1C;
				else count<=6'h1B;
			end
			end

			6'h1D: begin  message<=8'b00000111; if(avail) spistart<=0; end 

			endcase 
		end
	endcase
	end
	 
endmodule
	 
