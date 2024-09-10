# Proyecto Tamagotchi, entrega 1

* Angela Sofia Ortiz Oliveros
* Linda Marcela Orduy Polania
* Juan David Gonzalez Muñoz
* David Santiago Cuellar Lopez


***
## Introducción

Este proyecto se centra en la creación de un tamagotchi (mascota virtual) mediante el uso de una FPGA y diversos componentes que mejoren la visualización e interacción con el hardware que se va a crear. Se tiene planeado inicialmente utilizar una pantalla LCD de Nokia para la visualización de la mascota y sus estados, junto con esto se tienen diversos componentes extra como una fotorresistencia y un sensor de ultrasonido, además de los botones ya integrados en la tarjeta, que serán de ayuda para generar una mayor interacción del usuario con su mascota virtual. Todo será programado en Verilog e implementado por medio de Quartus.

***

## Especificación detallada del sistema

### Perifericos

Detalle de la especificación de los componentes del proyecto y su descripción funcional.

| Componente  | Especificación | Funcionamiento|
| ------------- | ------------- | ------------- |
| Botón Curar  | Pulsador FPGA  | MODO NORMAL: Cada que se oprima, aumentará el estado de Health. Tendrá un tiempo de recuperación y visualización en la pantalla. MODO TEST: Cada que se oprima, disminuirá el estado seleccionado con Botón Cambio Estado. |
| Botón Alimentar | Pulsador FPGA  | MODO NORMAL: Cada que se oprima, aumentará el estado de Food. Tendrá un tiempo de recuperación y visualización en la pantalla. MODO TEST: Cada que se oprima, aumentará el estado seleccionado con Botón Cambio Estado. |
| Botón Reset | Pulsador FPGA  | Cuando esté presionado por 5 segundos, se restablecerá el estado inicial del tamagotchi (todos los niveles igual a 5). |
| Botón Test| Pulsador FPGA  | Cuando esté presionado por 5 segundos, permitirá modificar directamente los estados haciendolos aumentar o disminuir. Esto se podrá hacer mediante el uso de los botones Cambio Estado, Alimentar y Curar. Tendrá visualización en la pantalla mientras se encuentre en ese estado. |
| Botón Cambio Estado  | Pulsador adicional  | Solo funcionará en modo test y cada que se oprima, cambiara el estado que puede afectar. |
| Sensor de Ultrasonido | Sensor HC-SR04 | Cuando detecte una proximidad, la mascota aumentará su estado de Fun, simulando un juego. Tendrá un tiempo minimo de interacción y visualización en la pantalla. |
| Sensor de Luz | FOTOCELDA LDR | Cuando no le entre luz, la mascota aumentará su estado de Sleep, simulando un periodo de sueño. Tendrá un tiempo minimo de interacción y visualización en la pantalla. |
| Pantalla | LCD Nokia 5110 | Será la visualización principal, se mostrarán los valores de estado del tamagotchi, su estado actual y las interacciones que realicen con el. |
| Leds 7 segmentos | Ánodo | Se utilizará para conocer el estado en el cual se encuentra el Botón Cambio Estado. |
| FPGA | A-C4E6 Cyclone IV FPGA EP4CE6E22C8N | Controlador de las distintas operaciones que se desean hacer (contiene componentes lógicos programables). |

### Caja Negra General

[<img src="fig/CAJA NEGRA DEFINITIVA.jpeg" width="800" alt="CAJA NEGRA DEFINITIVA"/>](fig)

#### Sensor de ultrasonido HC-SR04

_Este es un sensor ultrasónico que tiene una capacidad de detección dentro de un rango entre 0.3 a 3 metros de distancia, y tiene la siguiente descripción de pines[1]._

[<img src="fig/HC-SR04-Ultrasonic.pdf.png" width="400" alt="Pines Sensor ultrasónico"/>](fig)

Se utiliza el contador de la FPGA para generar un pulso de duración específica (típicamente de 10 microsegundos) en el pin Trigger, posteriormente, aunque no de forma inmediata, el pin Echo se mantiene en alto mientras el sensor está recibiendo el eco. El ancho de pulso de esta señal es proporcional a la distancia al objeto.

* Sistema de Caja Negra

[<img src="fig/CAJA NEGRA ULTRA.jpeg" width="400" alt="Sensor ultrasónico"/>](fig)


#### Pantalla LCD Nokia 5110

_Es una pantalla blanco y negro usada anteriormente en los teléfonos de marca Nokia. Tiene 84*48 pixeles monocromáticos (84 columnas y 48 filas) para visualización, se lograr la conexión mediante el método de comunicación SPI que acepta esta pantalla._

[<img src="fig/Nokia-5110-LCD-Pinout-diagram-details.webp" width="300" alt="Pines LCD"/>](fig)

En esta pantalla se mostrará a la mascota virtual así como las diferentes reacciones que pueda llegar a tener dependiendo del nivel de sus estados y las interacciones que se realicen con ella. Los niveles de los estados tendrán una escala de 1 a 5 y se verán reflejados en la pantalla como barras.

* Sistema de Caja Negra

[<img src="fig/CAJA NEGRA LCD.jpeg" width="500" alt="CAJA NEGRA LCD"/>](fig)


#### Sensor de luz con Fotorresistencia

_Resistencia que varía en función de la luz que incide sobre su superficie, cuanto mayor sea la intensidad de la luz que incide menor será su resistencia y cuanta menos luz incida mayor será su resistencia. El voltaje de salida digital es un “0” lógico cuando la intensidad de luz es alta y es un “1” lógico cuando sucede lo contrario._

[<img src="fig/modulo-sensor-ldr.jpg" width="250" alt="Pines Sensor de luz"/>](fig)

Se usará un sensor de luz para determinar cuando la mascota podrá descansar. Cuando el sensor no detecte luz este enviara una señal, después de un tiempo, para que la mascota virtual pueda descansar y así aumentar su nivel Sleep.

* Sistema de Caja Negra

[<img src="fig/CAJA NEGRA FOTO.jpeg" width="400" alt="Sensor de luz"/>](fig)

## Arquitectura del Sistema

### Estados

La maquina de estados, funcionará en ciclos de 90 segundos para aumentar o disminuir los valores de los estados.

El Tamagotchi tendrá una serie de estados que reflejaran ciertas necesidades físicas y emocionales, como los siguientes:

| Estado | Descripción | Consecuencia Health |
| ------------- | ------------- | ------------- |
| Food | Cada que pasen 30, 60 o 90 segundos, se disminuye Food. Si se obtiene la señal que indica Alimentar, se aumenta Food. | Si food es menor a 3, cada que pasen 20, 55 o 85 segundos, se disminuirá Health. |
| Sleep | Cada que pasen 18, 49 o 86 segundos, se disminuye Sleep. Si se obtiene la señal que indica Dormir, se aumenta Sleep. | Si Sleep es menor a 3, cada que pasen 34 o 75 segundos, se disminuirá Health. |
| Fun | Cada que pasen 25, 50, 73, o 89 segundos, se disminuye Fun. Si se obtiene la señal que indica Diversión, se aumenta Fun. | Si Fun es menor a 3, cada que pasen 33 o 77 segundos, se disminuirá Health. |
| Happy | Cada que pasen 23, 47, 69 o 83 segundos, sí se tiene que Food y Fun son menores que 3, se disminuye Happy. Cada que pasen 22 o 70 segundos, sí se tiene que Food y Fun son mayores que 3, se aumenta Food. | Si Happy es menor a 3, cada que pasen 2, 32 o 62 segundos, se disminuirá Health. |
| Health | Sí se obtiene la señal de curar, se aumentará Health. | _No se altera_|

### Diagramas de Maquinas de Estados

[<img src="fig/FSMgrafico.jpg" width="1000" alt="Diagrama de flujo"/>](fig)

Se decidió realizar 5 maquinas de estados que operan de manera paralela cada una con sus propias señales. Estas señales cambian dependiendo del tiempo y de condiciones predefinidas, los estados de cada una de las maquinas se dividen entre los estados que disminuyen el valor del estado de la mascota, los que lo aumentan y los que disminuyen Health.

Los estados de los valores de estado de la mascota son los siguientes:

#### Food (comida)
* IDLEFOOD: inicializa los valores en 0.
* HUNGER: disminuye el valor de Food si han pasado los segundos necesarios.
* FEED: aumenta el valor de Food si se ha recibido la señal de alimentar.
* STARVE: disminuye el valor del estado de Health si han pasado los segundos necesarios.
#### Sleep (descanso)
* IDLESLEEP: inicializa los valores en 0.
* TIRED: disminuye el valor de Sleep si han pasado los segundos necesarios.
* REST: aumenta el valor de Sleep si se ha recibido la señal de dormir.
* INSOMNIA: disminuye el valor del estado de Health si han pasado los segundos necesarios.
#### Fun (diversión)
* IDLEFUN: inicializa los valores en 0.
* BOREDOM: disminuye el valor de Fun si han pasado los segundos necesarios.
* PLAY: aumenta el valor de Fun si se ha recibido la señal de alimentar.
* DEPRESSION: disminuye el valor del estado de Health si han pasado los segundos necesarios.
#### Happy (animo)
* IDLEHAPPY: inicializa los valores en 0.
* SAD: disminuye el valor de Happy si han pasado los segundos necesarios.
* JOLLY: aumenta el valor de Happy si se ha recibido la señal de alimentar.
* SADNESS: disminuye el valor del estado de Health si han pasado los segundos necesarios.
#### Health (salud)
* IDLEHEALTH: inicializa los valores en 0.
* HEAL: aumenta el valor de Health si se ha recibido la señal de alimentar.






### Mascota

Se escogió un conejo como el avatar/mascota del tamagotchi y se diseñó usando pixeles para facilitar su ṕosterior implementación en código. Este es el diseño principal y sobre el cual se basaran las interacciones de la mascota.

 [<img src="fig/Bunny.png" width="300" alt="Diseño mascota"/>](fig)




# Referencias
[1] “HC-SR04 Ultrasonic Sensor Module User Guide,” *HandsOnTech*. https://www.handsontec.com/dataspecs/HC-SR04-Ultrasonic.pdf

[2]“Nokia5110 LCD Module,” *Microcontrollers Lab*, Ene. 28, 2020. https://microcontrollerslab.com/nokia5110-lcd-pinout-arduino-interfacing-datasheet/ 

[3]Philips Semiconductors, “PCD8544 Datasheet ,” *Sigma Electronica*, Abr. 12, 1999. https://www.sigmaelectronica.net/manuals/NOKIA%205110.pdf 

[4] UAEH, “Fotorresistencia ,” *Arduino UAEH*, 2021. http://ceca.uaeh.edu.mx/informatica/oas_final/red4_arduino/fotorresistencia.html
