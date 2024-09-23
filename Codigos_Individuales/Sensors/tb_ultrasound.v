`timescale 1ns/1ps

module tb_ultrasound;

    // Inputs
    reg clk;
    reg echo;

    // Outputs
    wire trigger;
    wire object_detected;

    // Instantiate the Device Under Test (DUT)
    ultrasound uut (
        .clk(clk), 
        .trigger(trigger), 
        .echo(echo), 
        .object_detected(object_detected)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // Reloj con un período de 20 ns (50 MHz)
    end

    // Test sequence
    initial begin
        // Initialize Inputs
        echo = 0;
		  
        
        // Espera inicial para reset
        #100;
        
        // Simulación de eco detectado (objeto dentro del rango)
        echo = 1;  
        #200;     // Espera para simular el tiempo del eco
        echo = 0;
		  
        
        // Simulación de eco sin detectar (objeto fuera del rango)
        #300;
        echo = 1;
        #500;
        echo = 0;
        
        // Termina la simulación
        #100;
        $stop;
    end

endmodule
