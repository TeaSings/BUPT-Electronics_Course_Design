module bottle_counter (
    input clk,
    input clr,
    input count_en,
    input config_set,
    input inc_bottle,
    input [3:0] target_low, // 这里留着给以后也许要设置装瓶最大值
    input [3:0] target_high,

    output reg [3:0] output_low,
    output reg [3:0] output_high,
    output reg done // 同样留作装瓶数量满足目标的输出信号
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
        done <= 1'b0;
    end else begin
        if (config_set) begin
            output_low <= 4'd0;
            output_high <= 4'd0;
            done <= 1'b0;
        end else if (count_en && inc_bottle) begin
            if (next_low == target_low && next_high == target_high) begin
                output_low <= target_low;
                output_high <= target_high;
                done <= 1'b1;
            end else begin
                output_high <= next_high;
                output_low <= next_low;
            end
        end
    end
end
endmodule
