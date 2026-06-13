module second_counter (
    input clr,
    input clk,
    input tick,
    input set_en,
    input [3:0] set_low,
    input [3:0] set_high,
    output reg [3:0] output_low,
    output reg [3:0] output_high
);
always @ (posedge clk or negedge clr) begin
    if (!clr) begin
        output_low <= 4'd0;
        output_high <= 4'd0;
    end else begin
        if (set_en) begin
            output_low <= set_low;
            output_high <= set_high;
        end else if (tick) begin
            if (output_low == 4'd9) begin
                output_low <= 4'd0;
                if (output_high == 4'd5) begin
                    output_high <= 4'd0;
                end else begin
                    output_high <= output_high + 1'b1;
                end
            end else begin
                output_low <= output_low + 1'b1;
            end
        end
    end
end
endmodule
