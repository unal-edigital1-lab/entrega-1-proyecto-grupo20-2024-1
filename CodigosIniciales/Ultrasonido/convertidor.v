module convertidor (
    input  wire [15:0] counter2,
    output reg [15:0] distance
);

speed_sound= 1

always @(*) begin
    distance = counter2 * speed_sound;
end

endmodule
