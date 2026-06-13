module bcd_to_7_seg (
    input wire [3:0] led,
    output reg [6:0] light
);

always @(*) begin
    case (led)
        4'b0000: light = 7'b0111111;
        4'b0001: light = 7'b0000110;
        4'b0010: light = 7'b1011011;
        4'b0011: light = 7'b1001111;
        4'b0100: light = 7'b1100110;
        4'b0101: light = 7'b1101101;
        4'b0110: light = 7'b1111101;
        4'b0111: light = 7'b0000111;
        4'b1000: light = 7'b1111111;
        4'b1001: light = 7'b1101111;
        default: light = 7'b0000000;
    endcase
end
endmodule
