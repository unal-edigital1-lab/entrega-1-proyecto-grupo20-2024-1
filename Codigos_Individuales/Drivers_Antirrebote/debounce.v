`timescale 1s / 1ns

//Función antirebote para un botón
//El antirebote evita que el circuito detecte múltiples pulsaciones de un botón 
//cuando solo se presiona una vez debido al ruido eléctrico :D

module debounce(  
    input pb,
    input clk,
    output out_signal,
    output out1
);

wire clk_out;
wire Q1, Q2, Q2_bar, Q3, Q4, Q4_bar;
reg out = 0;

Slow_clock U1(.clk_in(clk), .clk_out(clk_out));
DD_FF d1(.clk(clk_out), .D(pb), .Q(Q1));
DD_FF d2(.clk(clk_out), .D(Q1), .Q(Q2));

assign Q2_bar = ~Q2;
assign out_signal = Q1 & Q2_bar; 

DD_FF d3(.clk(clk), .D(out_signal), .Q(Q3));
DD_FF d4(.clk(clk), .D(Q3), .Q(Q4));

assign Q4_bar = ~Q4;
assign out1 = Q3 & Q4_bar; 

endmodule