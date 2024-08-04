# Proyecto Tamagotchi, entrega 1

* Angela Sofia Ortiz Oliveros
* Linda Marcela Orduy Polania
* Juan David Gonzalez Muñoz
* David Santiago Cuellar Lopez

## Contenido [sección de guía eliminar despues]
Objetivo: Definición periféricos del proyecto y diseño inicial.

Esperado:

* Especificación detallada del sistema (Completo).
    - a) Detalle de la especificación de los componentes del proyecto, su descripción funcional y sistema de caja negra.
    - b) Uso de un lenguaje adecuado para describir el sistema.
    - c) Utilización de diagramas de conexión claros para describir cada módulo y especificar los bloques funcionales en HW.

* Plan inicial de la arquitectura del sistema (Solo a y b).
    - a) Definición clara de la funcionalidad de cada periférico y coherencia con la implementación en HDL y su conexión.
    - b) Capacidad para decidir la arquitectura más adecuada del proyecto y replanteamiento de modelos.
* Documentación inicial en el repositorio de Git (a y b).
    - a) Consolidación de la documentación en un repositorio de Git, incluyendo texto, imágenes y videos de los criterios anteriormente expuestos.
    - b) Organización clara y estructurada de la documentación, facilitando la comprensión del proyecto y el seguimiento del proceso.

***
## Introducción

Este proyecto se centra en la creación de un tamagotchi (mascota virtual) mediante el uso de una FPGA y diversos componentes que mejoren la visualización e interacción con el hardware que se va a crear. Se tiene planeado inicialmente utilizar una pantalla LCD de Nokia, además de los leds integrados en la tarjeta, para la visualización de la mascota y sus estados. Junto con esto se tienen diversos componentes extra como una fotorresistencia y un sensor de ultrasonido, además de los botones ya integrados en la tarjeta, que serán de ayuda para generar una mayor interacción del usuario con su mascota virtual. Todo será programado en Verilog e implementado por medio de Quartus.


***
# Componentes

## HC-SR04

_Este es un sensor ultrasónico que tiene una capacidad de detección dentro de un rango entre 0.3 a 3 metros de distancia, y tiene la siguiente descripción de pines[1]._

* Especificación

   * Detalles
        - Voltaje de alimentación DC: 3V- 5V
        - Consumo de corriente en reposo: < 2mA
        - Corriente de operación : 15mA
        - Rango de detección: 2cm a 400cm ± 3mm
        - Ángulo efectivo 15º
        - Dimensiones: 45 mm x 20 mm x 15 m

[<img src="fig/HC-SR04-Ultrasonic.pdf.png" width="400" alt="Pines Sensor ultrasónico"/>](fig)

Este sensor tiene 4 pines de conexión como se ve en la imagen, donde (de izquierda a derecha) 1 es VCC (power cathode), 2 es la entrada, 3 es la salida proporcional a la distancia (ECHO) y 4 es ground (power anode).

* Descripción Funcional


* Sistema de Caja Negra

[<img src="fig/Proximidad.jpg" width="400" alt="Pines Sensor ultrasónico"/>](fig)


## LCD Nokia 5110

_Es una pantalla blanco y negro usada anteriormente en los teléfonos de marca Nokia. Esta se puede utilizar para mostrar caracteres alfanuméricos, dibujar formas e incluso mapas de bits por medio de sus 84*48 pixeles monocromáticos (84 columnas y 48 filas), esto se puede lograr mediante el método de comunicación SPI que acepta esta pantalla._

* Especificaciones

    * Detalles
        - Diseñado para trabajar de 2.7v a 3.3v
        - Niveles de comunicación de 3v
        - Salidas de 48 filas y 84 columnas
        - RES (reset) externo
        - Interfas serial maxima de 40 Mbits/s
        - Entradas compatibles con CMOS
        - Mux rate: 48
        - Rango de voltaje del display, 6v a 8.5v con voltaje LCD generado internamente o 6v a 9v con voltaje LCD suministrado externamente.
        - Bajo consumo, adecuado para trabajar con sistemas de baterias
        - Rango de temperatura: -25°C a +70°C    

[<img src="fig/Nokia-5110-LCD-Pinout-diagram-details.webp" width="300" alt="Pines LCD"/>](fig)



* Descripción Funcional


* Sistema de Caja Negra

[<img src="fig/Pantalla.jpg" width="400" alt="Pines Sensor ultrasónico"/>](fig)


## Fotoresistencia

_Es una resistencia que varía en función de la luz que incide sobre su superficie, cuanto mayor sea la intensidad de la luz que incide en la superficie del LDR menor será su resistencia y cuanta menos luz incida mayor será su resistencia. Para nuestro caso esto se traducirá como un 1 y un 0 dependiendo de que no supere cierto nivel de luz en su superficie._

* Especificaciones

    * Detalles
        - Fabricado en semiconductor de alta resistencia
        - En la oscuridad, resistencia varia entre 1MΩ; bajo alta intensidad de luz, resistencia varia entre 100Ω
        - Cambio de intensidad luminica tiene una respuesta de una décima de segundo
        - De muy bajo costo y tecnología sencilla

* Descripción Funcional


* Sistema de Caja Negra

[<img src="fig/Fotores.jpg" width="400" alt="Pines Sensor ultrasónico"/>](fig)

## LEDS 7 Segmentos

_Es un dispositivo opto-electrónico que permite visualizar números y/o letras dependiendo de lo que se requiera. De estos existen 2 tipos, el de ánodo común y el de cátodo común y como están construidos con diodos LED requiere una corriente máxima.Su estructura es estándar en cuanto al nombre de los segmentos, donde a cada uno se le asigna una letra de la "a" a la "g" como se muestra a continuación:_

* Especificaciones

    * Detalles
        - Voltaje de Operación Típico: 5V con el uso de Resistencias de 120 Ω.
        - Corriente de consumo por segmento: 20 mA.
        - Polaridad: Ánodo y Cátodo Común.
        - Tamaño del Display: 14 mm.
        - Color: Rojo.
        - Dimensiones: 12.6 mm x 19 mm x 8 mm
    

    [<img src="fig/Display-7-segmentos.jpg" width="200" alt="LED 7 segmentos"/>](fig)

Este funciona al activar y desactivar cada uno de los leds, formando lo que se desea visualizar al apagar y prender cada uno de los leds.

* Descripción Funcional


* Sistema de Caja Negra

[<img src="fig/Led7Seg.jpg" width="400" alt="Pines Sensor ultrasónico"/>](fig)

# Arquitectura del Sistema

## Funcionamiento

### Estados

Inicialmente el Tamagotchi tendrá una serie de estados que reflejaran ciertas necesidades físicas y emocionales, como los siguientes:

* Hambre: Indica la necesidad de alimentar a la mascota. 
  - La falta de atención a esta necesidad puede disminuir el estado de Salud.
* Diversión: Indica la necesidad de entretenimiento de la mascota. 
  - La inactividad prolongada puede disminuir el estado de Animo.
  - La actividad ocasional mantendrá un estado de Animo óptimo y de vez en cuando disminuira el estado de Energía.
* Energía: Indica cuando la mascota requiere reposo para recuperar energía.
  - EL estado de Energía disminuye después de períodos de actividad intensa o si se mantiene despierta a la mascota durante el periodo de noche.
  - El bajo nivel del estado de Energía disminuye el estado de Salud de la mascota.
* Salud: Refleja el cuidado general de la mascota.
  - Puede disminuir por el bajo nivel del estado de Hambre y de Energía de la mascota.
  - Cuando es bajo se requieren intervenir para su recuperación.
  - Un estado de Salud igual a 1 indica el fin del juego.
* Ánimo: Refleja el bienestar general de la mascota.
  - Aumenta y se mantiene en niveles óptimos al mantener los demás estados en niveles altos.

### Perifericos

* Botones

    - Reset: Reestablece el Tamagotchi a un estado inicial conocido al mantener pulsado el botón durante al menos 5 segundos. Este estado inicial simula el despertar de la mascota con sus estados óptimos.
    -  Test: Activa el modo de prueba al mantener pulsado el botón durante al menos 5 segundos, permitiendo al usuario navegar entre los diferentes estados del Tamagotchi con los botones de interacción.
    - Botón de Interacción (a): Alimentar a la mascota aumenta su estado de Hambre, pueden haber varios alimentos y algunos de ellos pueden estar contaminados, disminuyendo el estado de Salud.
    - Botón de Interacción (b): Curar a la mascota aumenta su estado de Salud y evita el empeoramiento de los demas estados.

* Sensores

    - Sensor Fotorresistencia: cuando se cubra el sensor (no sensa luz) la mascota entrará en estado de descanso.
      - El estado de descanso permitirá aumental el estado de Energía dependiendo del tiempo en estado de descanso. 
      - En el estado de descanso la mascosta no interactuará con nosotros de ninguna manera hasta que se descubra el sensor (sensa luz nuevamente) donde estará lista para interactuar nuevamente.
    - Sensor Ultrasonido: dependiendo de si hay un obstaculo o no en el rango de visión del sensor, la mascota lo tomará como un obstaculo a saltar que aumentará su estado de Diversión, permitiendonos simular un juego con la mascota.

* Pantalla LCD
  * En esta pantalla se mostrará a la mascota virtual y las diferentes reacciones que pueda llegar a tener dependiendo del nivel de sus estados y las interacciones que se realicen con ella.

  * Además esta pantalla tiene la opción de variar la "backlight" que se relacionará con el periodo de día o noche.

* LEDS
  * Los LEDS de 7 segmentos se encargarán de mostrar el nivel de cada uno de los estados con un valor que variará entre 1 y 8. Siendo 8 el estado óptimo y 1 el estado pésimo.


## Mascota 

Se escogió un conejo como el avatar/mascota del tamagotchi y se diseñó usando pixeles para facilitar su ṕosterior implementación en código. Este es el diseño principal y sobre el cual se basaran las interacciones de la mascota.

 [<img src="fig/Bunny.png" width="300" alt="Diseño mascota"/>](fig)



# Referencias
[1] “HC-SR04 Ultrasonic Sensor Module User Guide,” *HandsOnTech*. https://www.handsontec.com/dataspecs/HC-SR04-Ultrasonic.pdf

[2]“Nokia5110 LCD Module,” *Microcontrollers Lab*, Ene. 28, 2020. https://microcontrollerslab.com/nokia5110-lcd-pinout-arduino-interfacing-datasheet/ 

[3]Philips Semiconductors, “PCD8544 Datasheet ,” *Sigma Electronica*, Abr. 12, 1999. https://www.sigmaelectronica.net/manuals/NOKIA%205110.pdf 

[4] UAEH, “Fotorresistencia ,” *Arduino UAEH*, 2021. http://ceca.uaeh.edu.mx/informatica/oas_final/red4_arduino/fotorresistencia.html
