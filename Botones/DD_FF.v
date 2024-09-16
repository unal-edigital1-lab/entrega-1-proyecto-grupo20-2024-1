`timescale 1s / 1ns

// Este módulo implementa un flip-flop D
// La salida Q toma el valor de la entrada D en el flanco positivo del reloj


module DD_FF(
    input clk,
    input D,
    output reg Q,
    output reg Qbar
);

always @ (posedge clk)
begin 
Q <= D;
Qbar <= !Q;
end 

endmodule