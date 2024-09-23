`timescale 1ns/1ps

module tb_photoSensor;

    // Entradas
    reg clk;
    reg ldr_input;

    // Salidas
    wire day_night;

    // Parâmetros para o período do clock
    parameter integer clk_period = 20;  // 50 MHz clock (20 ns period)

    // Instanciando el dispositivo bajo prueba (DUT)
    photoSensor uut (
        .clk(clk), 
        .ldr_input(ldr_input), 
        .day_night(day_night)
    );

    // Generación del reloj
    always begin
        clk = 1; 
        #(clk_period / 2);  // Mitad del período para el flanco positivo
        clk = 0; 
        #(clk_period / 2);  // Mitad del período para el flanco negativo
    end

    // Bloque inicial para la simulación
    initial begin
        // Inicialización de las entradas
        ldr_input = 0;  // Comenzamos simulando una condición de "noche" (sin luz)

        // Esperar algunos ciclos de reloj
        #100;

        // Simular cambio a "día" (entrada de luz)
        ldr_input = 1;
        #200;  // Esperar 200 ns en la condición de "día"

        // Volver a "noche" (sin luz)
        ldr_input = 0;
        #200;  // Esperar 200 ns en la condición de "noche"

        // Simular cambios rápidos entre día y noche
        ldr_input = 1;
        #50;   // "Día" por 50 ns
        ldr_input = 0;
        #50;   // "Noche" por 50 ns

        // Finalizar la simulación
        #100;
        $stop;
    end

endmodule
