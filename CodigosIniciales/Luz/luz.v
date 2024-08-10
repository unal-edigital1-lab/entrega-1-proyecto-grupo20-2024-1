module luz (
    input clk,            // Reloj del sistema
    input ldr_input,      // Entrada de la señal de la fotorresistencia (a través del transistor)
    output reg day_night       // Salida: 1 (día) / 0 (noche)
);

always @(posedge clk) begin
    day_night <= ldr_input;
end

endmodule