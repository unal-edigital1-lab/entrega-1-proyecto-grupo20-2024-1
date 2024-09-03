/*
5.1.1 Modo Test

El modo Test permite a los usuarios y desarrolladores validar la funcionalidad del sistema y sus estados sin necesidad de seguir el flujo de operación normal. En este modo, se pueden forzar transiciones de estado específicas mediante interacciones simplificadas, como pulsaciones cortas de botones, para verificar las respuestas del sistema y la visualización. Este modo es esencial durante la fase de desarrollo para pruebas rápidas y efectivas de nuevas características o para diagnóstico de problemas.

    Activación: Se ingresa al modo Test manteniendo pulsado el botón "Test" por un periodo de 5 segundos.
    Funcionalidad: Permite la navegación manual entre los estados del Tamagotchi, ignorando los temporizadores o eventos aleatorios, para observar directamente las respuestas y animaciones asociadas.

	 
5.1.2 Modo Normal

El Modo Normal es el estado de operación estándar del Tamagotchi, donde la interacción y respuesta a las necesidades de la mascota virtual dependen enteramente de las acciones del usuario.

    Activación: El sistema arranca por defecto en el Modo Normal tras el encendido o reinicio del dispositivo. No requiere una secuencia de activación especial, ya que es el modo de funcionamiento predeterminado.

    Funcionalidad: Los usuarios interactúan con la mascota a través de botones y, potencialmente, sensores para satisfacer sus necesidades básicas. La mascota transita entre diferentes estados (por ejemplo, Hambriento, Feliz, Dormido, Enfermo) en respuesta a las acciones del usuario y al paso del tiempo. El sistema proporciona retroalimentación inmediata sobre las acciones mediante la visualización.
5.2.1. Estados Mínimos

El Tamagotchi operará a través de una serie de estados que reflejan las necesidades físicas y emocionales de la mascota virtual, a saber:

    Hambriento: Este estado alerta sobre la necesidad de alimentar a la mascota. La falta de atención a esta necesidad puede desencadenar un estado de enfermedad.

    Diversión: Denota la necesidad de entretenimiento de la mascota. La inactividad prolongada puede llevar a estados de aburrimiento o tristeza.

    Descansar: Identifica cuando la mascota requiere reposo para recuperar energía, especialmente después de períodos de actividad intensa o durante la noche, limitando la interacción del usuario durante estas fases.

    Salud: va a niveles de enfermo por el descuido en el cuidado de la mascota, requiriendo intervenciones específicas para su recuperación.

    Feliz: Refleja el bienestar general de la mascota como resultado de satisfacer adecuadamente sus necesidades básicas.
*/


module core(
	//in and out physical
	input clock,
	input Reset,
	output mosi,
	output sclk,
	output sce,
	output dc,
	output rst,
	output reg back,
	output reg led
	);

	reg [3:0] hambre;
	reg [3:0] draw;
	wire mascota;
	wire done;

	reg [6:0] count=4'h0;

  spi_configBunny Configbunny(
    .clock(clock),
    .Reset(Reset),
    .mosi(mosi),
    .sclk(sclk),
    .sce(sce),
    .dc(dc),
    .rst(rst),
    .nivel_hambre(hambre),
    .draw(draw),
    .mascota(mascota),
    .done(done)
  );

  always @(posedge clock) begin
	back<=0;
	
	case(count)
    4'h0: begin 
      draw<=4'h0;
		if (mascota) begin
        hambre<=4'h3;
        draw<=4'h1; 
		  led<=0;
		  if(done) count<=4'h1;
		end
    end 

    //4'h0: begin  hambre<=4'h3; draw<=4'h0; if (done) count<=4'h1; end
    4'h1: begin draw<=4'h2; if (done) count<=4'h2; end
    4'h2: begin draw<=4'h3; if (done) count<=4'h3; end
    4'h3: begin draw<=4'h4; if (done) count<=4'h4; end
    4'h4: begin draw<=4'h5; end /*if (done) count<=4'h5; end
    4'h5: begin draw<=4'h6; end*/

    endcase 
  end
endmodule



      
      



