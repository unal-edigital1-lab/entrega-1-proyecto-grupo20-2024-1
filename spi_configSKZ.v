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


module spi_config(
   input clock,
	input Reset,
	//salidas reales
	output mosi,
	output sclk,
	output sce,
	output dc,
	output rst,
	output reg back
	//output reg [2:0]test,
	//output reg [7:0] message
	);
	
	//registros a utilizar/modificar en este modulo
	reg [7:0] message;
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
	parameter SKZ=4'h1;
	
	reg [10:0] i=0;
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
			4'h0:begin  spistart<=1;	comm<=0; 
			if (avail) count<=4'h1;
			end
			
			4'h1: begin message<=8'b00100001;
			if (avail) count<=4'h2;
			end
			
			4'h2:begin  message<=8'b10010000;	 
			if (avail) count<=4'h3;
			end
			
			4'h3: begin message<=8'b00100000; 
			if(avail) count<=4'h4;
			end
			
			4'h4: begin	message<=8'b00001100; 
			if(avail) count<=4'h5;
			end
			
			4'h5: begin	 comm<=1; message<=8'h0; //limpia la pantalla
			if(avail) begin 
				if (i<=503) begin 
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
		
		SKZ: begin //dibujar
			poss_x<=8'h23;
			poss_y<=8'h42;
			back<=0;	
			case(count)
				4'h0: begin comm<=0; message<=poss_x;
			if(avail) count<=4'h1;
			end
			
			4'h1: begin  message<=poss_y; 
			if(avail) count<=4'h2;
			end
			
			4'h2: begin comm<=1; message<=8'b00001001;//mas entendible en binario
			if(avail) count<=4'h3;
			end
			
			4'h3: begin message<=8'b00010101;
			if(avail) count<=4'h4;
			end
			
			4'h4: begin message<=8'b00010101;
			if(avail) count<=4'h5;
			end
			
			4'h5: begin  message<=8'b00010010;
			if(avail) count<=4'h6;
			end
			
			4'h6: begin comm<=0; poss_x<=poss_x+5; message<=poss_x; 
			if(avail) count<=4'h7;
			end
			
			4'h7: begin comm<=1;	message<=8'b00011111;
			if(avail) count<=4'h8;
			end
			
			4'h8: begin message<=8'b00000100;
			if(avail) count<=4'h9;
			end
			
			4'h9: begin message<=8'b00001010;
			if(avail) count<=4'hA;
			end
			
			4'hA: begin message<=8'b00010001;
			if(avail) count<=4'hB;
			end
			
			4'hB: begin comm<=0; poss_x<=poss_x+5; message<=poss_x; 
			if(avail) count<=4'hC;
			end

			4'hC: begin message<=8'b00010011;
			if(avail) count<=4'hD;
			end

			4'hD: begin message<=8'b00010101;
			if(avail) count<=4'hE;
			end

			4'hE: begin message<=8'b00011001;
				if(avail) count<=4'hF;
			end

			4'hF: begin message<=8'b00010001;
				if(avail) spistart<=0;
			end
			
			endcase 
		end
	endcase
	end
	 
endmodule
	 
