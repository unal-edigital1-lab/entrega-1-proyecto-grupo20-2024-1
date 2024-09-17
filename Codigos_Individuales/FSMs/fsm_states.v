`timescale 1ns / 1ps

module fsm_states (
       input clk,
       input rst,
       input feeding,
       input light_out,
       input echo_sig,
       input healing,
       input change_state,
       input test,
       output [2:0] foodValue,
       output [2:0] sleepValue,
       output [2:0] funValue,
       output [2:0] happyValue,
       output [2:0] healthValue,
	   output [2:0] stateTest // ver cual estado se esta modificando
    );
/* // señales directas de fpga negadas
assign feeding = ~feeding1;
assign light_out = ~light_out1;
assign echo_sig = ~echo_sig1;
assign healing = ~healing1;
assign change_state = ~change_state1;
assign test = ~test1;
*/

//Se conectan las salidas con las variables locales
assign stateTest = state+1;
assign foodValue = value_food;
assign sleepValue = value_sleep;
assign funValue = value_fun;
assign happyValue = value_happy;
assign healthValue = value_health;

    reg test_mode = 0;
    reg [2:0] state = 0;

    reg [2:0] value_food = 5;
    reg [2:0] value_sleep = 5;
    reg [2:0] value_fun = 5;
    reg [2:0] value_happy = 5;
    reg [2:0] value_health = 5;

// Variables de subida de nivel, bajada de nivel y bajada de salud dependiendo del nivel
    reg upFood = 0;
    reg upSleep = 0;
    reg upFun = 0;
    reg upHappy = 0;
    reg upHealth = 0;

    reg downFood  = 0;
    reg downSleep  = 0;
    reg downFun  = 0;
    reg downHappy  = 0;

    reg heal_downFood = 0;
    reg heal_downSleep = 0;
    reg heal_downFun = 0;
    reg heal_downHappy = 0;

// PRIMERA PARTE FSM, asignacion de estado a los niveles
    always @(posedge clk) begin
        food_state <= (rst == 0) ? IDLEFOOD : next_stateFood;
        sleep_state <= (rst == 0) ? IDLESLEEP : next_stateSleep;
        fun_state <= (rst == 0) ? IDLEFUN : next_stateFun;
        happy_state <= (rst == 0) ? IDLEHAPPY : next_stateHappy;
        health_state <= (rst == 0) ? IDLEHEALTH : next_stateHealth;
    end

parameter FOOD2 = 3'b000, SLEEP2 = 3'b001, FUN2 = 3'b010, HAPPY2 = 3'b011 , HEALTH2 = 3'b100;

    always @(posedge clk) begin
        // activacion de modo test
        test_mode <= (test == 1) ? ~test_mode : test_mode;
        if (rst == 0) begin
            value_food = 5;
            value_sleep = 5;
            value_fun = 5;
            value_happy = 5;
            value_health = 5;
        // estado de muerte 
        end else if (value_health == 1) begin
            value_food = 0;
            value_sleep = 0;
            value_fun = 0;
            value_happy = 0;
            value_health = 0;
        // subida y bajada de niveles en modo normal
        end else if (test_mode == 0) begin
            value_food <= (upFood == 1 && value_food < 5 && value_food > 0) ? value_food+1: (downFood == 1 && value_food < 6 && value_food > 1) ? value_food-1: value_food;
            value_sleep <= (upSleep == 1 && value_sleep < 5 && value_sleep > 0) ? value_sleep+1: (downSleep == 1 && value_sleep < 6 && value_sleep > 1) ? value_sleep-1: value_sleep;
            value_fun <= (upFun == 1 && value_fun < 5 && value_fun > 0) ? value_fun+1: (downFun == 1 && value_fun < 6 && value_fun > 1) ? value_fun-1: value_fun;
            value_happy <= (upHappy == 1 && value_happy < 5 && value_happy > 0) ? value_happy+1: (downHappy == 1 && value_happy < 6 && value_happy > 1) ? value_happy-1: value_happy;
            value_health <= (upHealth == 1 && value_health < 5 && value_health > 0) ? value_health+1: ((heal_downFood == 1 || heal_downSleep || heal_downFun || heal_downHappy) && value_health < 6 && value_health > 1) ? value_health-1: value_health;
        end else begin
            // variable para escoger nivel a alterar
            state <= (change_state == 1) ? (state == 4) ? 0 : state+1 : state; 
            // subida y bajada de niveles en modo test
            case(state)
                FOOD2: value_food <= (feeding == 1 && value_food < 5 && value_food > 0) ? value_food+1 : (healing == 1 && value_food < 6 && value_food > 1) ? value_food-1 : value_food;
                SLEEP2: value_sleep <= (feeding == 1 && value_sleep < 5 && value_sleep > 0) ? value_sleep+1 : (healing == 1 && value_sleep < 6 && value_sleep > 1) ? value_sleep-1 : value_sleep;
                FUN2: value_fun <= (feeding == 1 && value_fun < 5 && value_fun > 0) ? value_fun+1 : (healing == 1 && value_fun < 6 && value_fun > 1) ? value_fun-1 : value_fun;
                HAPPY2: value_happy <= (feeding == 1 && value_happy < 5 && value_happy > 0) ? value_happy+1 : (healing == 1 && value_happy < 6 && value_happy > 1) ? value_happy-1 : value_happy;
                HEALTH2: value_health <= (feeding == 1 && value_health < 5 && value_health > 0) ? value_health+1 : (healing == 1 && value_health < 6 && value_health > 1) ? value_health-1 : value_health;
            endcase
        end
    end

// contador de ciclos de 90 segundo
parameter freq = 50; //50000000 MHz equivalen a 1 segundo, 50 para simular
reg [6:0] sec_count = 0; // segundos hasta 128
reg [25:0] counter = 0; //Contador de 26 bits 

    always @(posedge clk) begin 
        if (counter == freq) begin
            sec_count <= (sec_count == 90) ? 0 : sec_count+1; // se reinician los segundos o aumenta contador segundos
            counter <= 0; // se reinicia el contador 
        end else begin 
            counter <= counter+1;
        end 
    end

parameter IDLEFOOD = 2'b00, HUNGER = 2'b01, FEED = 2'b10, STARVE = 2'b11;
reg [1:0] food_state = IDLEFOOD;
reg [1:0] next_stateFood = 2'b00;

parameter IDLESLEEP = 2'b00, TIRED = 2'b01, REST = 2'b10, INSOMNIA = 2'b11;
reg [1:0] sleep_state = IDLESLEEP;
reg [1:0] next_stateSleep = 2'b00;

parameter IDLEFUN = 2'b00, BOREDOM = 2'b01, PLAY = 2'b10, DEPRESSION = 2'b11;
reg [1:0] fun_state = IDLEFUN;
reg [1:0] next_stateFun = 2'b00;

parameter IDLEHAPPY = 2'b00, SAD = 2'b01, JOLLY = 2'b10, SADNESS = 2'b11;
reg [1:0] happy_state = IDLEHAPPY;
reg [1:0] next_stateHappy = 2'b00;

parameter IDLEHEALTH = 1'b0, HEAL = 1'b1;
reg [1:0] health_state = IDLEHEALTH;
reg [1:0] next_stateHealth = 1'b0;

// SEGUNDA PARTE FSM, logica de cambio de estados
    always @(*) begin
        case(food_state)
            IDLEFOOD: next_stateFood <= HUNGER;
            HUNGER: next_stateFood <= (feeding == 1) ? FEED : (value_food < 3 && counter == 0) ? STARVE : HUNGER;
            FEED: next_stateFood <= HUNGER;
            STARVE: next_stateFood <= HUNGER;
        endcase
        case(sleep_state)
            IDLESLEEP: next_stateSleep <= TIRED;
            TIRED: next_stateSleep <= (light_out == 1) ? REST : (value_sleep < 3 && counter == 0) ? INSOMNIA : TIRED;
            REST: next_stateSleep <= TIRED;
            INSOMNIA: next_stateSleep <= TIRED;
        endcase
        case(fun_state)
            IDLEFUN: next_stateFun <= BOREDOM;
            BOREDOM: next_stateFun <= (echo_sig == 1) ? PLAY : (value_fun < 3 && counter == 0) ? DEPRESSION : BOREDOM;
            PLAY: next_stateFun <= BOREDOM;
            DEPRESSION: next_stateFun <= BOREDOM;
        endcase
        case(happy_state)
            IDLEHAPPY: next_stateHappy <= SAD;
            SAD: next_stateHappy <= (value_food > 3 && value_fun > 3 && counter == 0) ? JOLLY : (value_food < 3 && value_fun < 3 && counter == 0) ? SADNESS : SAD;
            JOLLY: next_stateHappy <= SAD;
            SADNESS: next_stateHappy <= SAD;
        endcase
        case(health_state)
            IDLEHEALTH: next_stateHealth <= (healing == 1) ? HEAL : IDLEHEALTH;
            HEAL: next_stateHealth <= IDLEHEALTH;
        endcase
    end

// TERCERA PARTE FSM, consecuencias de cambios de estados
    always @(posedge clk) begin
        if (rst == 0) begin
            // comida señales
            downFood  <= 0;
            upFood <= 0;
            heal_downFood <= 0;
            // dormir señales
            downSleep  <= 0;
            upSleep <= 0;
            heal_downSleep <= 0;
            // diversion señales
            downFun  <= 0;
            upFun <= 0;
            heal_downFun <= 0;
            // animo señales
            upHappy <= 0;
            downHappy  <= 0;
            heal_downHappy <= 0;
            // salud señales
            upHealth <= 0;
        end else begin
            case(food_state)
                IDLEFOOD: begin
                    downFood <= 0;
                    heal_downFood <= 0;
                    upFood <= 0;
                end
                HUNGER: begin
                    downFood <= ((sec_count == 30 || sec_count == 60 || sec_count == 90) && counter == 0) ? 1 : 0;
                    heal_downFood <= 0;
                    upFood <= 0;
                end
                FEED: begin 
                    downFood <= 0;
                    heal_downFood <= 0;
                    upFood <= 1;
                end
                STARVE: begin
                    downFood <= 0;
                    heal_downFood <= (sec_count == 20 || sec_count == 55 || sec_count == 85) ? 1 : 0;
                    upFood <= 0;
                end 
            endcase
            case(sleep_state)
                IDLESLEEP: begin
                    downSleep <= 0;
                    heal_downSleep <= 0;
                    upSleep <= 0;
                end
                TIRED: begin
                    downSleep <= ((sec_count == 18 || sec_count == 49 || sec_count == 86) && counter == 0) ? 1 : 0;
                    heal_downSleep <= 0;
                    upSleep <= 0;
                end
                REST: begin 
                    downSleep <= 0;
                    heal_downSleep <= 0;
                    upSleep <= 1;
                end
                INSOMNIA: begin
                    downSleep <= 0;
                    heal_downSleep <= (sec_count == 34 || sec_count == 75) ? 1 : 0;
                    upSleep <= 0;
                end 
            endcase
            case(fun_state)
                IDLEFUN: begin
                    downFun <= 0;
                    heal_downFun <= 0;
                    upFun <= 0;
                end
                BOREDOM: begin
                    downFun <= ((sec_count == 25 || sec_count == 50 || sec_count == 73 || sec_count == 89) && counter == 0) ? 1 : 0;
                    heal_downFun <= 0;
                    upFun <= 0;
                end
                PLAY: begin 
                    downFun <= 0;
                    heal_downFun <= 0;
                    upFun <= 1;
                end
                DEPRESSION: begin
                    downFun <= 0;
                    heal_downFun <= (sec_count == 1 || sec_count == 33 || sec_count == 77) ? 1 : 0;
                    upFun <= 0;
                end 
            endcase
            case(happy_state)
                IDLEHAPPY: begin
                    upHappy <= 0;
                    downHappy <= 0;
                    heal_downHappy <= 0;
                end
                SAD: begin
                    upHappy <= 0;
                    downHappy <= ((sec_count == 23 || sec_count == 47 || sec_count == 69 || sec_count == 83) && counter == 0 && (value_fun < 4 || value_food < 4)) ? 1 : 0;
                    heal_downHappy <= 0;
                end
                JOLLY: begin 
                    upHappy <= (sec_count == 4 || sec_count == 22 || sec_count == 52 || sec_count == 70) ? 1: 0;
                    downHappy <= 0;
                    heal_downHappy <= 0;
                end
                SADNESS: begin
                    upHappy <= 0;
                    downHappy <= 0;
                    heal_downHappy <= (sec_count == 2 || sec_count == 32 || sec_count == 62) ? 1 : 0;
                end 
            endcase
            case(health_state)
                IDLEHEALTH: begin
                    upHealth <= 0;
                end
                HEAL: begin
                    upHealth <= 1;
                end
            endcase
        end
    end

endmodule