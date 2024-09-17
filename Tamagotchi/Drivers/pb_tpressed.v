
module pb_tpressed(  
    input pb_in,
    input clk,
    output signal_out
);

//Para activar reset, se mantiene presionado cierto tiempo
localparam LIMIT = 200000000; //Numero de ciclos 

//Ancho de esta variable determinada automáticamente en función del valor de LIMIT"
reg [$clog2(LIMIT)+1:0] flag_counter;
reg pb_out;
wire Q2, Q3;

//Llamamos al flip flop tipo D
DD_FF d1(.clk(clk), .D(pb_out), .Q(Q2));
DD_FF d2(.clk(clk), .D(Q2), .Q(Q3));

assign Q3_bar = ~Q3;
assign signal_out = Q2 & Q3_bar; 


initial begin
    pb_out = 0;
    flag_counter = 0;
end

//Tener en cuenta logica negada para la FPGA

always @(posedge clk) begin
    if (pb_in == 1) begin 
        flag_counter <= flag_counter + 1;
        if (flag_counter == LIMIT) begin 
        flag_counter <= 0;
        pb_out <= 1;
        end 
    end 
    // Resetear el contador si el botón no esta presionado o se suelta antes de 5 sec
    else begin
        flag_counter <= 0;
        pb_out <= 0;
    end
end



endmodule 