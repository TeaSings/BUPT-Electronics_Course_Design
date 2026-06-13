module display_mux (
    input  wire [3:0] target_bottle_high,
    input  wire [3:0] target_bottle_low,
    input  wire [3:0] max_pill_high,
    input  wire [3:0] max_pill_low,

    input  wire [3:0] output_bottle_high,
    input  wire [3:0] output_bottle_low,
    input  wire [3:0] output_pill_high,
    input  wire [3:0] output_pill_low,     // 药片个位BCD（原信号名 seg_output_pill_low）

    input wire [3:0] d2,
    input wire [3:0] d1,
    input wire [3:0] c2,
    input wire [3:0] c1,

    input  wire [1:0] state,
    input  wire [1:0] disp_sel,

    output reg [3:0] disp6,
    output reg [3:0] disp5,
    output reg [3:0] disp4,
    output reg [3:0] disp3,
    output reg [3:0] disp2
);

// 状态编码（与status_signal一致）
localparam INIT    = 2'b00;
localparam RUNNING = 2'b01;
localparam FAULT   = 2'b10;
localparam PAUSE   = 2'b11;

always @(*) begin
    // 默认值：全0
    disp6 = 4'd0;
    disp5 = 4'd0;
    disp4 = 4'd0;
    disp3 = 4'd0;
    disp2 = 4'd0;

    case (state)
        FAULT: begin
            // 故障状态：全部显示“8”
            disp6 = 4'd8;
            disp5 = 4'd8;
            disp4 = 4'd8;
            disp3 = 4'd8;
            disp2 = 4'd8;
        end

        INIT: begin
            // 初始化状态：显示配置参数（高位在前）
            disp5 = target_bottle_high;
            disp4 = target_bottle_low;
            disp3 = max_pill_high;
            disp2 = max_pill_low;
            // disp6 保持0
        end

        RUNNING: begin
            if (disp_sel == 2'b00) begin
                // 显示配置参数
                disp5 = target_bottle_high;
                disp4 = target_bottle_low;
                disp3 = max_pill_high;
                disp2 = max_pill_low;
            end else if (disp_sel == 2'b01) begin
                // 显示实时计数值
                disp5 = output_bottle_high;
                disp4 = output_bottle_low;
                disp3 = output_pill_high;
                disp2 = output_pill_low;
            end
            else begin
                // 显示实时计数值
                disp5 = d2;
                disp4 = d1;
                disp3 = c2;
                disp2 = c1;
            end
        end

        PAUSE: begin
            // PAUSE状态最高位显示全1（4'hF），表示任务完成
            disp6 = 4'hF;
            if (disp_sel == 2'b00) begin
                // 显示配置参数
                disp5 = target_bottle_high;
                disp4 = target_bottle_low;
                disp3 = max_pill_high;
                disp2 = max_pill_low;
            end else if (disp_sel == 2'b01) begin
                // 显示实时计数值
                disp5 = output_bottle_high;
                disp4 = output_bottle_low;
                disp3 = output_pill_high;
                disp2 = output_pill_low;
            end
            else begin
                // 显示实时计数值
                disp5 = d2;
                disp4 = d1;
                disp3 = c2;
                disp2 = c1;
            end
        end

        default: begin
            // 异常状态恢复默认全0
        end
    endcase
end

endmodule
