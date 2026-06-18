module status_signal (
    input  wire        clk,
    input  wire        clr,              // 低有效异步复位

    input  wire        continue_en,         // 电平信号
    input  wire        confirm_pulse,          // 边沿触发

    input  wire        done,
    input  wire        warn,
    input  wire        config_valid,

    output reg         config_set,
    output reg         run,
    output reg [1:0]   dis_state
);

// 状态编码
localparam INIT    = 2'b00;
localparam RUNNING = 2'b01;
localparam FAULT   = 2'b10;
localparam PAUSE   = 2'b11;

reg [1:0] current_state, next_state;

// 第一段：时序逻辑 —— 状态寄存器
always @(posedge clk or negedge clr) begin
    if (!clr) begin
        current_state <= INIT;
    end else begin
        current_state <= next_state;
    end
end

// 第二段：组合逻辑 —— 次态生成与输出
always @(*) begin
    // 默认值
    next_state = current_state;
    config_set = 1'b0;
    run        = 1'b0;
    dis_state  = current_state;    // 直接输出当前状态编码

    case (current_state)
        INIT: begin
            config_set = 1'b1;       // 只有 INIT 状态允许设置
            run = 1'b0;
            if (warn)
                next_state = FAULT;
            else if (config_valid)
                next_state = RUNNING;
        end

        FAULT: begin
            config_set   = 1'b0;
            run          = 1'b0;
            // FAULT 状态下无 config_set 和 run
            if (confirm_pulse)
                next_state = INIT;
        end

        RUNNING: begin
            run = 1'b1;              // 只有 RUNNING 状态使能计数
            config_set   = 1'b0;
            if (done)
                next_state = PAUSE;
            else if (confirm_pulse)
                next_state = PAUSE;
        end

        PAUSE: begin
            config_set   = 1'b0;
            run          = 1'b0;
            // done=1 时保持 PAUSE，否则等待 confirm 脉冲
            // if (!done && confirm_pulse)
            //     next_state = RUNNING;
            // 否则保持 PAUSE（包括 done=1 和无脉冲的情况）
            if (done && confirm_pulse) begin
                next_state = INIT;
            end
            else if (!done && confirm_pulse && continue_en) begin
                next_state = RUNNING;
            end
            else if (!done && confirm_pulse && !continue_en) begin
                next_state = INIT;
            end
        end

        default: begin
            next_state = INIT;
            config_set = 1'b0;
            run        = 1'b0;
        end
    endcase
end

endmodule
