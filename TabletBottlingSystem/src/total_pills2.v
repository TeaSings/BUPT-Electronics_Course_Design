module total_pills (
    input clk,
    input clr,      // 低电平有效复位
    input config_set,
    input start,    // 计数使能 run

    output reg [3:0] c1,   // 个位 BCD
    output reg [3:0] c2,   // 十位 BCD
    output reg [3:0] d1,   // 百位 BCD
    output reg [3:0] d2    // 千位 BCD
);

// 内部 BCD 计数器寄存器
reg [3:0] ones;     // 个位
reg [3:0] tens;     // 十位
reg [3:0] hundreds; // 百位
reg [3:0] thousands;// 千位

always @(posedge clk or negedge clr) begin
    if (!clr) begin
        // 异步复位（低电平有效）
        ones <= 4'd0;
        tens <= 4'd0;
        hundreds <= 4'd0;
        thousands <= 4'd0;
    end else if (config_set) begin
        ones <= 4'd0;
        tens <= 4'd0;
        hundreds <= 4'd0;
        thousands <= 4'd0;
    end else if (start) begin
        // 计数使能：个位加1，并处理 BCD 进位
        if (ones == 4'd9) begin
            ones <= 4'd0;
            if (tens == 4'd9) begin
                tens <= 4'd0;
                if (hundreds == 4'd9) begin
                    hundreds <= 4'd0;
                    thousands <= thousands + 4'd1;
                end else begin
                    hundreds <= hundreds + 4'd1;
                end
            end else begin
                tens <= tens + 4'd1;
            end
        end else begin
            ones <= ones + 4'd1;
        end
    end
end

// 将内部计数器值输出到端口
always @(posedge clk or negedge clr) begin
    if (!clr) begin
        c1 <= 4'd0;
        c2 <= 4'd0;
        d1 <= 4'd0;
        d2 <= 4'd0;
    end else begin
        c1 <= ones;
        c2 <= tens;
        d1 <= hundreds;
        d2 <= thousands;
    end
end

endmodule
