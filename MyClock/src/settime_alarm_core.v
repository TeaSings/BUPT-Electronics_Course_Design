module settime_alarm_core
(
    // 时钟与复位
    input           clk,
    input           clr,

    // 模式选择：00 正常走时，01 设置当前时间，10 设置闹钟，11 保留
    input [1:0]     mode_sel,
    input           alarm_enable_sw,

    // 用户操作按键
    input           ui_select,   // 切换编辑字段：0 为小时，1 为分钟
    input           ui_inc,      // 递增当前编辑字段
    input           ui_confirm,  // 确认操作

    // 当前走时时间，来自 time_core
    input [3:0]     cur_hour_high,
    input [3:0]     cur_hour_low,
    input [3:0]     cur_min_high,
    input [3:0]     cur_min_low,

    // 设置/显示用 BCD 输出
    output reg[3:0] disp_hour_high,
    output reg[3:0] disp_hour_low,
    output reg [3:0] disp_min_high,
    output reg [3:0] disp_min_low,

    // 闹钟匹配与响铃请求
    output          alarm_match,
    output          alarm_ring_req,

    // 设置当前时间时，确认键产生一拍加载脉冲
    output          time_load_en,

    // 当前编辑字段：0 为小时，1 为分钟
    output reg      field_output,

    output speaker
);

//========================================================================
// 1. 按键边沿检测
// 拨动开关和自锁按键都按边沿处理，电平变化时产生单拍脉冲。
//========================================================================
reg ui_select_d, ui_inc_d, ui_confirm_d;
always @(posedge clk or negedge clr) begin
    if (!clr) begin
        ui_select_d  <= 1'b0;
        ui_inc_d     <= 1'b0;
        ui_confirm_d  <= 1'b0;

    end else begin
        ui_select_d  <= ui_select;
        ui_inc_d     <= ui_inc;
        ui_confirm_d <= ui_confirm;
    end
end

// 按键脉冲
wire sel_pulse   = ui_select  ^ ui_select_d;
wire inc_pulse   = ui_inc & ~ui_inc_d;
wire conf_pulse  = ui_confirm ^ ui_confirm_d;

//========================================================================
// 2. 内部寄存器
//========================================================================
reg [3:0] alarm_hour_high, alarm_hour_low; // 闹钟小时 BCD
reg [3:0] alarm_min_high,  alarm_min_low;
reg [1:0] mode_sel_d;                     // 上一拍模式，用于检测模式切换
// reg       time_load_en_r;                 // 加载脉冲寄存器

//========================================================================
// 3. 闹钟匹配与响铃请求
//========================================================================
assign alarm_match = (cur_hour_high == alarm_hour_high) &&
(cur_hour_low  == alarm_hour_low)  &&
(cur_min_high  == alarm_min_high)  &&
(cur_min_low   == alarm_min_low);

// 闹钟总开关打开、时间匹配且不在闹钟设置模式时响铃
assign alarm_ring_req = alarm_enable_sw && alarm_match && (mode_sel != 2'b10);
assign speaker = (alarm_ring_req == 1'b1) ? clk : 1'b0;
//assign speaker = clk;

//========================================================================
// 4. 设置时间加载脉冲
//========================================================================
// assign time_load_en = time_load_en_r;
assign time_load_en = conf_pulse && (mode_sel == 2'b01);

//========================================================================
// 5. 主控制逻辑
//========================================================================
always @(posedge clk or negedge clr) begin
    if (!clr) begin
        // 异步复位，所有时间归零
        disp_hour_high <= 4'd0;
        disp_hour_low  <= 4'd0;
        disp_min_high  <= 4'd0;
        disp_min_low   <= 4'd0;
        alarm_hour_high <= 4'd0;
        alarm_hour_low  <= 4'd0;
        alarm_min_high  <= 4'd0;
        alarm_min_low   <= 4'd0;
        field_output    <= 1'b0;
        mode_sel_d      <= 2'b00;
        // time_load_en_r  <= 1'b0;
    end else begin
        // time_load_en 由组合赋值产生，这里保留原寄存器实现的注释
        // time_load_en_r <= 1'b0;

        //--------------------------------------------------------------
        // 5.1 模式切换：进入设置模式时载入对应初始值
        //--------------------------------------------------------------
        if (mode_sel != mode_sel_d) begin
            case (mode_sel)
                2'b01: begin  // 设置当前时间：载入当前走时时间
                    disp_hour_high <= cur_hour_high;
                    disp_hour_low  <= cur_hour_low;
                    disp_min_high  <= cur_min_high;
                    disp_min_low   <= cur_min_low;
                end
                2'b10: begin  // 设置闹钟：载入已保存的闹钟时间
                    disp_hour_high <= alarm_hour_high;
                    disp_hour_low  <= alarm_hour_low;
                    disp_min_high  <= alarm_min_high;
                    disp_min_low   <= alarm_min_low;
                end
                // 2'b00 正常模式：disp 在下面持续更新为当前时间
            endcase
        end

        // 保存当前模式，供下一拍比较
        mode_sel_d <= mode_sel;

        //--------------------------------------------------------------
        // 5.2 根据当前模式处理显示与调整
        //--------------------------------------------------------------
        if (mode_sel == 2'b00) begin
            // 正常走时模式：显示当前走时时间
            disp_hour_high <= cur_hour_high;
            disp_hour_low  <= cur_hour_low;
            disp_min_high  <= cur_min_high;
            disp_min_low   <= cur_min_low;
            field_output   <= 1'b0;       // 无活动字段
        end
        else if (mode_sel == 2'b01 || mode_sel == 2'b10) begin
            // 设置时间和设置闹钟共用相同调整逻辑
            // 字段切换
            if (sel_pulse)
                field_output <= ~field_output;

            // 递增当前字段
            if (inc_pulse) begin
                case (field_output)
                    1'b0: begin // 调整小时
                        if (disp_hour_high == 4'd2 && disp_hour_low == 4'd3) begin
                            // 23 -> 0
                            disp_hour_high <= 4'd0;
                            disp_hour_low  <= 4'd0;
                        end else if (disp_hour_low == 4'd9) begin
                            // 09,19 -> 十位加 1，个位归 0
                            disp_hour_low  <= 4'd0;
                            disp_hour_high <= disp_hour_high + 4'd1;
                        end else begin
                            disp_hour_low <= disp_hour_low + 4'd1;
                        end
                    end
                    1'b1: begin // 调整分钟
                        if (disp_min_high == 4'd5 && disp_min_low == 4'd9) begin
                            // 59 -> 0
                            disp_min_high <= 4'd0;
                            disp_min_low  <= 4'd0;
                        end else if (disp_min_low == 4'd9) begin
                            // 09,19,29,39,49 -> 十位加 1，个位归 0
                            disp_min_low  <= 4'd0;
                            disp_min_high <= disp_min_high + 4'd1;
                        end else begin
                            disp_min_low <= disp_min_low + 4'd1;
                        end
                    end
                endcase
            end

            // 确认操作
            if (conf_pulse) begin
                // if (mode_sel == 3'b001) begin
                // 设置当前时间模式：顶层读取 disp 并更新走时时钟
                // time_load_en_r <= 1'b1;
                // end else
                if (mode_sel == 2'b10) begin
                    // 设置闹钟模式：将当前显示值写入闹钟寄存器
                    alarm_hour_high <= disp_hour_high;
                    alarm_hour_low  <= disp_hour_low;
                    alarm_min_high  <= disp_min_high;
                    alarm_min_low   <= disp_min_low;
                end
            end
        end
        else begin
            // mode_sel == 2'b11 保留
            field_output <= 1'b0;
        end
    end
end

endmodule
