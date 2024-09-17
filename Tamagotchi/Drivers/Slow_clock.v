`timescale 1s / 1ns

// Genera un reloj lento para reducir la sensibilidad a los rebotes rapidos

module Slow_clock(
    input clk_in,
    output clk_out //4Hz slow clock 
);

reg [24:0] count = 0;
assign clk_out = clk_out1;
reg clk_out1 = 0; 

always @(posedge clk_in) begin 
        count <= count+1;
    if (count == 10000) begin //Este dato es igual a 50Mhz/8 countinit=6250000
        count <=0;
        clk_out1 = ~ clk_out1; // Niega el reloj de salida 
    end
end 

endmodule
