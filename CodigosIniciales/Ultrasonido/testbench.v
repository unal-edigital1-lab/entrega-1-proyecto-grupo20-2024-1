module hc_sr04_top (
    input  wire        clk,
    input  wire        reset,
);

// Señales internas
wire trigger, trigger_done, echo;
reg [15:0] counter2, distance;

// Instanciación de los módulos

trigger_generadorr tg (
        .clk(clk),
        .reset(reset),
        .trigger(trigger),
        .trigger_done(trigger_done)
    );

echo_time tof (
        .clk(clk),
        .reset(reset),
        .echo(echo),
        .counter2(counter2)
    );

convertidor dc (
        .clk(clk), 
        .counter2(counter2),
        .distance(distance)
    );

endmodule
