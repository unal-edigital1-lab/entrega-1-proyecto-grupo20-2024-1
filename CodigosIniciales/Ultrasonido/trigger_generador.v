module trigger_generador (
    input  wire        clk,
    input  wire        reset,
    output reg         trigger,
    output reg         trigger_done
);

parameter TRIGGER_PULSO = 500; // Ancho del pulso en ciclos de reloj (¿¿??)

reg [3:0] counter; // Registro de 4 bits llamado counter para contar los ciclos de reloj.

//Este bloque se ejecuta en cada flanco de subida del reloj o en un flanco de subida de reset.
always @(posedge clk or posedge reset) begin
    if (reset) begin // Al recibir un reset, se inicializan todas las señales.
        counter <= 0;
        trigger <= 0;
        trigger_done <= 0;
    end else begin
        if (counter == TRIGGER_PULSO) begin //Cuando el contador llega a TRIGGER_PULSO, se desactiva trigger y se activa trigger_done.
            counter <= 0;
            trigger <= 0;
            trigger_done <= 1;
        else if (counter == 0) begin // Si el contador es cero, se activa trigger para iniciar el pulso.
            trigger <= 1;
            end else begin
                counter <= counter + 1;   // El contador incrementa en cada flanco de subida del reloj hasta alcanzar TRIGGER_PULSO.
        end
    end
end

endmodule
