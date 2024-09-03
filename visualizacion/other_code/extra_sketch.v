CARROT: begin
			case(count)
        4'h0: begin  comm<=0; poss_x<=8'h8D; message<=poss_x; if(avail) count<=4'h1;end //CORREGIR
        4'h1: begin   poss_y<=8'h41; message<=poss_y; if(avail) count<=4'h2; end//PCORREGIR
				
        4'h2: begin  comm<=1; message<=8'b10000000; if(avail) count<=4'h3; end
        4'h3: begin  message<=8'b11000000; if(avail) count<=4'h4; end
        4'h4: begin  message<=8'b00100000; 
					if(avail) begin
            i<=i+1;
            if(i<=2) count<=4'h4; 
						else count<=4'h5;
          end
					end

        4'h5: begin  message<=8'b00111100; if(avail) count<=4'h6; end
        4'h6: begin  message<=8'b00100111; if(avail) count<=4'h7; end
        4'h7: begin  message<=8'b11100001; if(avail) count<=4'h8; end
        4'h8: begin  message<=8'b10011111; if(avail) count<=4'h9; end
        4'h9: begin  message<=8'b00111100; if(avail) count<=4'hA; end
        4'hA: begin  message<=8'b10010000; if(avail) count<=4'hB; end
        4'hB: begin  message<=8'b11010000; if(avail) count<=4'hC; end
        4'hC: begin  message<=8'b01010000; if(avail) count<=4'hD; end
        4'hD: begin  message<=8'b01110000; if(avail) count<=4'hE; end

         4'hE: begin  comm<=0; poss_x<=8'h8D; message<=poss_x; if(avail) count<=4'h1;end //CORREGIR
        4'hF: begin   poss_y<=8'h41; message<=poss_y; if(avail) count<=4'h2; end//PCORREGIR

         4'h10: begin  message<=8'b11110000; if(avail) count<=4'hE; end
          4'hD: begin  message<=8'b10011000; if(avail) count<=4'hE; end
          4'hD: begin  message<=8'b10001110; if(avail) count<=4'hE; end
          4'hD: begin  message<=8'b10001011; if(avail) count<=4'hE; end
          4'hD: begin  message<=8'b11011001; if(avail) count<=4'hE; end
        4'hD: begin  message<=8'b01000000; if(avail) count<=4'hE; end
          4'hD: begin  message<=8'b01100000; if(avail) count<=4'hE; end
          4'hD: begin  message<=8'b00110000; if(avail) count<=4'hE; end
          4'hD: begin  message<=8'b00010000; if(avail) count<=4'hE; end
          4'hD: begin  message<=8'b00011011; if(avail) count<=4'hE; end
          4'hD: begin  message<=8'b00001110; if(avail) count<=4'hE; end
          4'hD: begin  message<=8'b00000011; if(avail) count<=4'hE; end		
			
			
		endcase	
		end

SLEEPY: begin
			case(count)
        4'h0: begin  comm<=0; a<=0; poss_x<=8'h8D; message<=poss_x; if(avail) count<=4'h1;end //CORREGIR
        4'h1: begin   poss_y<=8'h41; message<=poss_y; if(avail) count<=4'h2; end//PCORREGIR
				
        4'h2: begin  comm<=1; message<=8'b11001000-a; if(avail) count<=4'h3; end
        4'h3: begin  message<=8'b10101000-a; if(avail) count<=4'h4; end
        4'h4: begin  message<=8'b10011000-a; if(avail) count<=4'h4; end
         4'h4: begin  message<=8'b10001000-a; 
           if(avail) begin 
             if(i==0)  count<=4'h4; 
             else if (i==1) count (cambio a ) 
               else if cambio estado 
             end
           end


                 endcase
                 end
        //cambiar posicion 
        nuevo valor a= 4'h64
        luego a=4'h32;



STAR: begin
			case(count)
        4'h0: begin  comm<=0; a<=0; poss_x<=8'h8D; message<=poss_x; if(avail) count<=4'h1;end //CORREGIR
        4'h1: begin   poss_y<=8'h41; message<=poss_y; if(avail) count<=4'h2; end//PCORREGIR
				
        4'h2: begin  comm<=1; message<=8'b0100000; if(avail) count<=4'h3; end
        4'h2: begin   message<=8'b10100000; if(avail) count<=4'h3; end
        4'h2: begin   message<=8'b0010000; if(avail) count<=4'h3; end//X3
        
        4'h2: begin   message<=8'b00011000; if(avail) count<=4'h3; end
        4'h2: begin   message<=8'b00000110; if(avail) count<=4'h3; end
        4'h2: begin   message<=8'b00000001; if(avail) count<=4'h3; end// repetir de regreso

        //cambio posicion 

        4'h2: begin   message<=8'b11100000; if(avail) count<=4'h3; end
        4'h2: begin   message<=8'b10011001; if(avail) count<=4'h3; end
        4'h2: begin   message<=8'b10000110; if(avail) count<=4'h3; end
        4'h2: begin   message<=8'b01000000; if(avail) count<=4'h3; end//X2

        4'h2: begin   message<=8'b00100000; if(avail) count<=4'h3; end
        4'h2: begin   message<=8'b00010000; if(avail) count<=4'h3; end //devolverse

    endcase	
		end


PART_CLEAN: begin //limpia alrededor del conejo
			case(count)
				4'h0: begin  spistart<=1; comm<=0; poss_x<=8'h0; message<=poss_x; if(avail) count<=4'h1;end 
			4'h1: begin   poss_y<=8'h43; message<=poss_y; if(avail) count<=4'h2;end
				
			4'h5: begin comm<=1; message<=8'h0; 
				if(avail) begin 
					if (i<=30) begin 
						i<=i+1;
						count<=4'h5;
					end 
					else begin 
						j<=j+1;
						if (j==0) count<=4'h6; 
						else count<=4'h7; 
					
					end
				end
			end

				4'h6: begin comm<=0; i<=0; poss_y<=poss_y-1; message<=poss_y; if(avail) count<=4'h5;end
				
				4'h7: begin comm<=0;  i<=0; poss_x<=8'hB2; message<=poss_x; if(avail) count<=4'h8;end
				4'h8: begin   poss_y<=8'h42; message<=poss_y; if(avail) count<=4'h9;end
				4'h9: begin comm<=1; message<=8'h0; 
				if(avail) begin 
					if (i<=14) begin 
						i<=i+1;
						count<=4'h9;
					end
					else count<=4'hA;
				end
				end

				4'hA: begin comm<=0; j<=0; i<=0;  poss_y<=8'h43; message<=poss_y; if(avail) count<=4'hB;end

				4'hB: begin comm<=1; message<=8'h0; 
				if(avail) begin 
					if (i<=18) begin 
						i<=i+1;
						count<=4'hB;
					end
					else begin 
						j<=j+1;
						if (j==0) count<=4'hC; 
						else count<=4'hE; 
					end
				end
				end

				4'hD: begin comm<=0; i<=0; poss_y<=poss_y-1; message<=poss_y; if(avail) count<=4'hB;end
				
				4'hE:begin spistart<=0; end
				
			
			endcase
		end

        
  







		   



          
