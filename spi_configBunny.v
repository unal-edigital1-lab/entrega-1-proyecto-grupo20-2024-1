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
	//salidas reales
	output mosi,
	output sclk,
	output sce,
	output dc,
	output rst,
	output reg back,
	output reg [7:0] message
	);
	
	//registros a utilizar/modificar en este modulo
	//reg [7:0] message;
	reg spistart; 
	reg comm;
	reg [7:0] poss_x;
	reg [7:0] poss_y;
  
	
	wire [15:0]freq_div;
	wire busy;
	wire avail;
	
	reg [4:0] state=4'h0;
	reg [4:0] count=4'h0;
	
	parameter INIT=4'h0;
	parameter BUNNY=4'h1;
	
	reg [8:0] i=0;
	reg [7:0] j=0;
	assign freq_div=25000000;//25000 freq deseada 1k (max 4M)div_factor 
	

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
		INIT:begin //configuracion 
			case(count)
			4'h0:begin  spistart<=1;	comm<=0; if (avail) count<=4'h1; end
				
			4'h1: begin message<=8'b00100001;if (avail) count<=4'h2; end
			
			4'h2:begin  message<=8'b10010000; if (avail) count<=4'h3; end
			 
			4'h3: begin message<=8'b00100000; if(avail) count<=4'h4; end
			
			4'h4: begin message<=8'b00001100; if(avail) count<=4'h5; end
			
			4'h5: begin comm<=1; message<=8'h0; //limpia la pantalla
			if(avail) begin 
				if (i<=510) begin 
					i<=i+1;
					count<=4'h5;
					end 
				else 
				begin 
				state<=4'h1;
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
			
			//4'h0:begin  spistart<=1;	comm<=0; if (avail) count<=4'h2; end
			4'h0: begin  comm<=0; message<=poss_x; if(avail) count<=4'h1;end
			4'h1: begin  message<=poss_y; if(avail) count<=4'h2; end
			
			4'h2: begin comm<=1; message<=8'b1111110; 
			if(avail) begin 
				if (j==2) count<=4'h6;
				else count<=4'h3;
			end
			end
			
			4'h3: begin  message<=8'b10000001;
         if(avail) begin
				i<=i+1;
            if(i<1) count<=4'h3;
				else count<=4'h4;
         end
			end
			
			4'h4: begin comm<=1; message<=8'b01111110; 
			if(avail) begin 
				if (i==2) begin i<=0; count<=4'h3; end
				else count<=4'h5;
			end
			end
			
			4'h5: begin comm<=1; message<=8'b001000000 ; 
			if(avail) begin 
				j<=j+1;
				if (j<1) count<=4'h5;
				else count<=4'h4;
			end
			end
			
			4'h6: begin  message<=8'h0; if(avail) spistart<=0; end 
			
			/*
			//-----
			
			4'h6: begin comm<=0; poss_x<=8'hA1; message<=poss_x; if(avail) count<=4'h6; end
			4'h6: begin poss_y<=poss_y-1; message<=poss_y; i<=1; if(avail) count<=4'h7; end
			
			4'h7: begin comm<=1;	message<=8'b00011111;
			if(avail) begin
				if(i==3)   count<=4'hB;
				else count<=4'h8;
			end
			end
			
			4'h8: begin message<=8'b00000100;
			if(avail) begin
			  if(i==3)   count<=4'h7;
			  else count<=4'h9;
			end
			end

			4'h9: begin message<=8'b00010011; 
			if(avail) begin
			  if(i==3)   count<=4'h8;
			  else count<=4'hA;
			end
			end

			4'hA: begin message<=8'b00000001; 
			if(avail) begin
				i<=i+1;
				if(i==1)   count<=4'hA;
				if(i==2) count<=4'h9;
			end
			end

			4'hB: begin comm<=0;	poss_x<= poss_x+5; message<=poss_x; i<=1; if(avail) count<=4'hC; end
			
			4'hC: begin message<=8'h00010000;
			if(avail) begin
				i<=i+1;
				if(i==1)   count<=4'hC;
				else count<=4'hD;
			end
			end
			

			//-----
			
			4'hD: begin comm<=0; poss_x<=8'hA1; message<=poss_x;  if(avail) count<=4'hE; end		
			4'hE: begin poss_y<=poss_y-1; message<=poss_y; if(avail) count<=4'hF; end
			4'hF: begin comm<=1; message<=8'h00001111; if(avail) count<=4'h10; end
			4'h10: begin  message<=8'h00011000; if(avail) count<=4'h11; end
			4'h11: begin  message<=8'h00010000; if(avail) count<=4'h12; end
			4'h12: begin  message<=8'h00000011; if(avail) count<=4'h13; end
			4'h13: begin comm<=0; poss_x<=poss_x+3; message<=poss_x;  if(avail) count<=4'h14;end
			4'h14: begin  message<=8'h00000011; if(avail) count<=4'h15; end
			4'h15: begin comm<=0; poss_x<=poss_x+3; message<=poss_x;  if(avail) count<=4'h16;end
			4'h16: begin  message<=8'h00000011; if(avail) count<=4'h17; end
			4'h17: begin  message<=8'h00000010; if(avail) count<=4'h17; end
			4'h18: begin comm<=0; poss_x<=poss_x+3; message<=poss_x;  if(avail) count<=4'h19; end
			4'h19: begin  message<=8'h00000111; if(avail) count<=4'h1A; end
			4'h1A: begin  message<=8'h00001100; if(avail) count<=4'h1B; end
			4'h1B: begin  message<=8'h00011000; if(avail) count<=4'h1C; end
			4'h1C: begin  message<=8'h00001001; if(avail) count<=4'h1D; end
			4'h1D: begin  message<=8'h00000110; if(avail) count<=4'h1E; end

			//------
			
			4'h1E: begin comm<=0; poss_x<=4'hA4; message<=poss_x;  if(avail) count<=4'h1F;	end
			4'h1F: begin poss_y<=poss_y-1; message<=poss_y; if(avail) count<=4'h20;end
			4'h20: begin comm<=1; message<=8'h00000001; if(avail) count<=4'h21; end
			4'h21: begin  message<=8'h00000001; if(avail) count<=4'h22; end
			4'h22: begin  message<=8'h00000011; if(avail) count<=4'h23; end
			4'h23: begin  message<=8'h00000111; if(avail) count<=4'h24; end 
			4'h24: begin  message<=8'h00001101; i<=1;  if(avail) count<=4'h25; end

			4'h25: begin message<=8'b00010000;
			if(avail) begin
				if(i==3) count<=4'h29;
				else count<=4'h26;
			end
			end

			4'h26: begin message<=8'b00010000;
			if(avail) begin
				if(i==3)   count<=4'h25;
				else count<=4'h27;
			end
			end

			4'h27: begin message<=8'b00011100; 
			if(avail) begin
				if(i==3)  count<=4'h26;
				else count<=4'h28;
			end
			end

			4'h28: begin message<=8'b00001000; 
			if(avail) begin
				i<=i+1;
				if(i==1) count<=4'h28;
				if(i==2) count<=4'h27;
			end
			end

			4'h29: begin  message<=8'b00001111; if(avail) spistart<=0; end 
*/
			endcase 
		end
	endcase
	end
	 
endmodule
	 
