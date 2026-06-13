module pill_counter (
    input clk,
    input clr,
    input count_en,
    //!!
    input config_set,

    input [3:0] max_low,
    input [3:0] max_high,

    output reg full_bottle_pulse,
    output reg [3:0] output_low,
    output reg [3:0] output_high
);

reg [3:0] next_low;
reg [3:0] next_high;

always @(*) begin
    if (output_low == 4'd9) begin
        next_low = 4'd0;
        next_high = output_high + 1'b1;
    end else begin
        next_low = output_low + 1'b1;
        next_high = output_high;
    end
end

always @(posedge clk or negedge clr) begin
    if (!clr) begin
        output_low <= 4'd0;
        output_high <= 4'd0;
        full_bottle_pulse <= 1'b0;
    end else begin
        full_bottle_pulse <= 1'b0;
        if (config_set) begin
            output_low <= 4'd0;
            output_high <= 4'd0;
            full_bottle_pulse <= 1'b0;
        end else if (count_en) begin
            if (next_high == max_high  && next_low == max_low ) begin
                output_low <= 4'd0;
                output_high <= 4'd0;
                full_bottle_pulse <= 1'b1;
            end else begin
                output_low <= next_low;
                output_high <= next_high;
            end
        end
    end
end
endmodule
