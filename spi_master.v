/*
Descripción:

  SPI CONFIG-->      _______________
                    |               |
           clk -----|               |
           rst -----|               |
 data_in [7:0] -----|               |---- sclk   ----->SPI SLAVE (NOKIA5110)
         start -----|               |---- mosi
freq_div[15:0] -----|               |---- miso (NO ESTA DISPONIBLE EN REALIDAD) 
data_out [7:0] <----|               |---- sce
          busy <----|               |---- dc
         avail <----|               |---- rst (pin reset en nokia) 
		command <-----|_______________|

CLK: 		Entrada del reloj del sistema.
RST: 		Señal de reset que inicializa el módulo.

CLOCK_DIV: Valor para configurar la velocidad de la comunicación SPI.

DATA_IN:  Datos que se van a transmitir al esclavo SPI.
DATA_OUT: Datos recibidos del esclavo.

START: 	Señal que inicia la transmisión de datos.
BUSY: 	Señal que indica si el módulo está ocupado en una transmisión.
AVAIL: 	Señal que indica que se ha recibido un dato completo.

MISO: 	Salida del Maestro, Entrada del Esclavo (Master In Slave Out).
MOSI: 	Entrada del Maestro, Salida del Esclavo (Master Out Slave In).
SCLK: 	Señal de reloj SPI que sincroniza la transmisión de datos.
sce: 		Chip Select, activa o desactiva el esclavo seleccionado.
DC:     Señal que indica si la entrada es un comando/direccion (0) o un dato de entrada a RAM (1)

*/

module spi_master(
   input clk,                // Reloj del sistema
   input reset,              // Señal de reset desde la fpga
   input [7:0] data_in,      // Datos de entrada para enviar
   input start,              // Inicio de la transmisión
   input [15:0] div_factor,   // Divisor del reloj para la velocidad SPI
   input  miso,          // Master In Slave Out
	input command,         //Señal que va a dc, se modifica en config por eso se pone como input
   output reg mosi,               // Master Out Slave In
   output reg sclk,          // Reloj SPI
   output reg sce,            // Chip Select
   output reg [7:0] data_out, // Datos recibidos
   output reg busy,          // Señal de ocupado
   output reg avail,  // Señal de dato recibido
	output reg dc,     //define si la entrada es un comando o data input
	output reg rst     //Señal reset a nokia
	);

   reg [7:0] shift_reg;
   reg [3:0] bit_count;
   reg [15:0] clk_count;
	reg active;
	

	always @(posedge clk or posedge reset) begin
	  if (reset) begin
			rst <=0;
			sclk <= 0;
			sce <= 1;
			shift_reg <= 0;
			bit_count <= 0;
			clk_count <= 0;
			active <= 0;
			busy <= 0;
			avail <= 0;
	  end else if (start && !active) begin
			rst <=1;
			active <= 1;
			avail <= 0;
			sce <= 0;
			bit_count <= 8;
			busy <= 1;
			shift_reg <= data_in;
			dc <= command;
	  end else if (active) begin
			mosi <= shift_reg[7];
			if (clk_count < div_factor - 1) begin
				 clk_count <= clk_count + 1;
			end else begin
				 clk_count <= 0;
				 sclk <= !sclk;
				 if (!sclk) begin
						mosi <= shift_reg[7];
				 end else begin
					  if (bit_count > 1) begin
							bit_count <= bit_count - 1;
							shift_reg <= {shift_reg[6:0], miso};
					  end else begin
							avail <= 1;
							data_out <= shift_reg;
							sce <= 1;
							active <= 0;
							busy <= 0;
					  end
				 end
			end
	  end
	end
endmodule
