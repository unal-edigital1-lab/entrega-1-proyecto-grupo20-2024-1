module echo_time (
    input  wire        clk,
    input  wire        reset,
    input  wire        echo,
    output reg [15:0] counter2
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        counter2 <= 0;
    end else begin
        if (echo) begin //El contador incrementa en cada flanco de subida del reloj mientras echo está en alto.
            counter2 <= counter2 + 1;
        end else if ( counter2 > 0) begin //Si echo es cero, el contador se reinicia 
            counter2 <= 0;
        end
    end
end

endmodule
