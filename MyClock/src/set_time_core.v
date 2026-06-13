module set_time_core (
    input        clk,
    input        clr,
    input        set_mode_en,

    input [1:0]  ui_select, // 00: 秒, 01: 分, 10: 时, 11: 无效
    input        ui_inc,
    // input        ui_dec, // 为减少资源占用，暂不实现递减逻辑
    input        ui_confirm,

    // 保留拨码输入接口位置，当前版本未使用
    // input  [3:0] set_low,
    // input  [3:0] set_high,

    output       time_load_en,
    output reg[3:0] sec_low,
    output reg[3:0] sec_high,
    output reg[3:0] min_low,
    output reg[3:0] min_high,
    output reg[3:0] hour_low,
    output reg[3:0] hour_high,

    output [6:0] seg_sec_low
);

// 按键上升沿检测
reg ui_inc_d, ui_confirm_d;
always @(posedge clk or negedge clr) begin
    if (!clr) begin
        ui_inc_d <= 1'd0;
        ui_confirm_d <= 1'd0;
    end else begin
        ui_inc_d <= ui_inc;
        ui_confirm_d <= ui_confirm;
    end
end

wire inc_pos     = ui_inc & ~ui_inc_d;
wire confirm_pos = ui_confirm & ~ui_confirm_d;

reg set_mode_d;
wire enter_set = set_mode_en & ~set_mode_d;
always @(posedge clk or negedge clr) begin
    if (!clr)
        set_mode_d <= 1'd0;
    else
        set_mode_d <= set_mode_en;
end

always @(posedge clk or negedge clr) begin
    if (!clr) begin
        sec_low <= 4'd0; sec_high <= 4'd0;
        min_low <= 4'd0; min_high <= 4'd0;
        hour_low <= 4'd0; hour_high <= 4'd0;
    end else if (enter_set) begin
        sec_low <= 4'd0;
        sec_high <= 4'd0;
        min_low <= 4'd0;
        min_high <= 4'd0;
        hour_low <= 4'd0;
        hour_high <= 4'd0;
    end else if (set_mode_en) begin
        if (inc_pos) begin
            case (ui_select)
                2'd0: begin // 秒
                    if (sec_low == 4'd9) begin
                        sec_low <= 4'd0;
                        sec_high <= (sec_high == 4'd5) ? 4'd0 : sec_high + 4'd1;
                    end
                    else sec_low <= sec_low + 1'd1;
                end
                2'd1: begin // 分
                    if (min_low == 4'd9) begin
                        min_low <= 4'd0;
                        min_high <= (min_high == 4'd5) ? 4'd0 : min_high + 4'd1;
                    end
                    else min_low <= min_low + 1'd1;
                end
                2'd2: begin // 时
                    if (hour_high == 4'd2) begin
                        if (hour_low == 4'd3) begin
                            hour_high <= 4'd0;
                            hour_low <= 4'd0;
                        end else begin
                            hour_low <= hour_low + 1'd1;
                        end
                    end else begin
                        if (hour_low == 4'd9) begin
                            hour_low <= 4'd0;
                            hour_high <= hour_high + 1'd1;
                        end else begin
                            hour_low <= hour_low + 1'd1;
                        end
                    end
                end
            endcase
        end
    end
end

reg time_load_en_d;
always @(posedge clk or negedge clr) begin
    if (!clr)
        time_load_en_d <= 0;
    else begin
        time_load_en_d <= 0;
        if (set_mode_en && confirm_pos) begin
            time_load_en_d <= 1;
        end
    end
end
assign time_load_en = time_load_en_d;

bcd_to_7_seg u_seg_sec_low_2 (
    .led(sec_low),
    .light(seg_sec_low)
);

endmodule
