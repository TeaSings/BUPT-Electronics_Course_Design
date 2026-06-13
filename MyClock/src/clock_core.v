module clock_core (
    input clk,
    input clr,
    input tick,

    input [1:0] mode_sel,  //k1-k0

    input ui_select,  //k3
    input ui_inc,          //qd
    input ui_confirm,      //k5

    input alarm_enable_sw,

    output [6:0] seg_sec_low,
    output [3:0] bcd_sec_high,
    output [3:0] bcd_min_low,
    output [3:0] bcd_min_high,
    output [3:0] bcd_hour_low,
    output [3:0] bcd_hour_high,

    output speaker
);
//设时模式信号控制
wire set_mode_en;
wire speaker_d;
assign set_mode_en = (mode_sel == 2'b01 || mode_sel == 2'b10);

//time_core的信号
wire [3:0] time_sec_low, time_sec_high, time_min_low, time_min_high;
wire [3:0] time_hour_low,time_hour_high;

wire [6:0] time_seg_sec_low;
//set_time_core的信号
wire time_load_en;
wire set_en = 1'b0;
wire [3:0] set_low = 4'd0;
wire [3:0] set_high = 4'd0;

wire [3:0] set_min_low, set_min_high;
wire [3:0] set_hour_low, set_hour_high;

wire [6:0] set_disp_sec_low;
wire field_output;
//alarm
wire alarm_match;
wire alarm_ring_req;

// 实例化 set_time_core
settime_alarm_core u_set_time (
    .clk(clk),
    .clr(clr),
    .mode_sel(mode_sel),

    .ui_select(ui_select),
    .ui_inc(ui_inc),
    .ui_confirm(ui_confirm),

    .alarm_enable_sw(alarm_enable_sw),

    .cur_hour_high(time_hour_high),
    .cur_hour_low(time_hour_low),
    .cur_min_high(time_min_high),
    .cur_min_low(time_min_low),

    .time_load_en(time_load_en),

    .disp_min_low(set_min_low),
    .disp_min_high(set_min_high),
    .disp_hour_low(set_hour_low),
    .disp_hour_high(set_hour_high),

    .field_output(field_output),
    .speaker(speaker_d),

    //.seg_sec_low(set_disp_sec_low)

    .alarm_match(alarm_match),
    .alarm_ring_req(alarm_ring_req)

);

time_core u_time_core(
    .clk(clk),
    .clr(clr),
    .tick(tick),
    .set_en(set_en),
    .set_low(set_low),
    .set_high(set_high),

    .time_load_en(time_load_en),
    .time_load_min_low(set_min_low),
    .time_load_min_high(set_min_high),
    .time_load_hour_low(set_hour_low),
    .time_load_hour_high(set_hour_high),

    .bcd_sec_low(time_sec_low),
    .seg_sec_low(time_seg_sec_low),
    .bcd_sec_high(time_sec_high),
    .bcd_min_low(time_min_low),
    .bcd_min_high(time_min_high),
    .bcd_hour_low(time_hour_low),
    .bcd_hour_high(time_hour_high)
);
wire [3:0] disp_min_low, disp_min_high;
wire [3:0] disp_hour_low, disp_hour_high;

assign speaker = (tick == 1'b1) ? speaker_d : 1'b0;

assign    disp_hour_high = ( tick==1'b1 && field_output==1'b0)? 4'b1111 : set_hour_high;
assign    disp_hour_low = ( tick==1'b1 && field_output==1'b0)? 4'b1111 : set_hour_low;
assign    disp_min_high = ( tick==1'b1 && field_output==1'b1)? 4'b1111 : set_min_high;
assign    disp_min_low = ( tick==1'b1 && field_output==1'b1)? 4'b1111 : set_min_low;
// !!set_mode_en已经改为2位宽
assign seg_sec_low  = set_mode_en ? 7'b0000000  : time_seg_sec_low;
assign bcd_sec_high = set_mode_en ? 4'b1111 : time_sec_high;
assign bcd_min_low  = set_mode_en ? disp_min_low  : time_min_low;
assign bcd_min_high = set_mode_en ? disp_min_high : time_min_high;
assign bcd_hour_low  = set_mode_en ? disp_hour_low  : time_hour_low;
assign bcd_hour_high = set_mode_en ? disp_hour_high : time_hour_high;

endmodule
