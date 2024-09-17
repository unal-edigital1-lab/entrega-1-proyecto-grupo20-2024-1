// Ya con esto esta para dos displays para mostrar dos numeros de 8 bits como maximo (255 en decimal :v)
/*`timescale 1ns / 1ps
`include "TamagotchiFSM/fsm_states.v"
`include "TamagotchiFSM/BCDtoSSeg.v"*/
`timescale 1ns / 1ps

module display(
    input clk,
	 input rst,
    output [0:6] sseg,
    output reg [2:0] an,
	 output reg [2:0] an1,
	 output led,
	 input [2:0] foodValue,
    input [2:0] sleepValue,
    input [2:0] funValue,
    input [2:0] happyValue,
    input [2:0] healthValue,
	 input [2:0] testValue
    );
 
	 
reg [5:0] bcd=0;
 
BCDtoSSeg bcdtosseg(.BCD(bcd), .SSeg(sseg));

reg [26:0] cfreq=0;
wire enable;

// Divisor de frecuecia

assign enable = cfreq[16];
assign led =enable;
always @(posedge clk) begin
  if(rst==0) begin
		cfreq <= 0;
	end else begin
		cfreq <=cfreq+1'b1;
	end
end


reg [2:0] count1 = 2'b0;

always @(posedge enable) begin

		if(rst==0) begin
			count1 <= 0;
			an <= 4'b1111; 
			an1 <= 4'b1111; 
		end else begin 
			an<=4'b0111; 
			an1<=4'b0111; 

//bcd obtiene el valor que se va a representar en el display, el 0 de an y an1 indica cual de los displays va a estar prendindo y el 1 cuales estarán apagados.
//Solo se tienen 5 casos porque solo se usarán 5 displays.
			case (count1) 
				3'h0: begin bcd <= foodValue;   an<=3'b1110; end 
				3'h1: begin bcd <= sleepValue;  an<=3'b1101; end 
				3'h2: begin bcd <= funValue;    an<=3'b1011; end 
				3'h3: begin bcd <= happyValue;  an1<=3'b110; end 
				3'h4: begin bcd <= healthValue; an1<=3'b101; end 
				3'h5: begin bcd <= testValue;   an1<=3'b011; end 
			endcase
			count1<= count1+1;
			if(count1==6) begin
				count1<=0;
			end
		end 
end

endmodule