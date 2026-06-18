// Divide a 10 kHz reference clock into a lower-frequency alert tone.
module spliter (
    input wire clk,
    input wire rst_n,
    output reg clk_out
);

reg [5:0] cnt;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 6'd0;
        clk_out <= 1'b0;
    end else begin
        if (cnt == 6'd49) begin
            cnt <= 6'd0;
            clk_out <= ~clk_out;
        end else begin
            cnt <= cnt + 1'd1;
        end
    end
end

endmodule
