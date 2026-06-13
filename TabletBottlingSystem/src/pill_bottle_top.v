module pill_bottle_top (
    input clk, //cp2 57
    input clr, // 1
    input start, // K1 81
    input tick, // cp3 58
    input [1:0] set_sel, // K3-K2 79-80
    input inc, // QD 60
    input confirm, // K0 54

    input [1:0] disp_sel, // K5-K4 76 77

    output [3:0] disp6, // 24 22 21 20
    output [3:0] disp5, // 29 28 27 25
    output [3:0] disp4, // 34 33 31 30
    output [3:0] disp3, // 18 17 36 35
    output [3:0] disp2, // 41 40 39 37

    output [1:0] disp_state

);
reg confirm_d;
always @(posedge clk or negedge clr) begin
    if (!clr) begin
        confirm_d     <= 1'b0;
    end else begin
        confirm_d     <= confirm;
    end
end
wire confirm_pulse = confirm ^ confirm_d; //confirm_pulse双边沿触发

wire [3:0] max_pill_low;
wire [3:0] max_pill_high;
wire [3:0] target_bottle_low;
wire [3:0] target_bottle_high;

wire config_valid;
wire warn;
wire config_set;
wire run;
wire [1:0] state;

wire [3:0] pill_low;
wire [3:0] pill_high;
wire [3:0] bottle_low;
wire [3:0] bottle_high;

wire [3:0] d2;
wire [3:0] d1;
wire [3:0] c2;
wire [3:0] c1;

config_core u_config_core (
    .clk(clk),
    .clr(clr),
    .start_setting(config_set),
    .set_sel(set_sel),
    .inc(inc),
    .confirm(confirm_pulse),
    .max_pill_low(max_pill_low),
    .max_pill_high(max_pill_high),
    .target_bottle_low(target_bottle_low),
    .target_bottle_high(target_bottle_high),
    .config_valid(config_valid),
    .warn(warn)
);

status_signal u_status_signal(
    .clk(clk),
    .clr(clr),              // 低有效异步复位

    .continue(start),            // 电平信号
    .confirm_pulse(confirm_pulse),          // 边沿触发

    .done(done),
    .warn(warn),
    .config_valid(config_valid),

    .config_set(config_set),
    .run(run),
    .dis_state(state)
);

display_mux u_display_mux(
    .max_pill_low(max_pill_low),
    .max_pill_high(max_pill_high),
    .target_bottle_low(target_bottle_low),
    .target_bottle_high(target_bottle_high),

    .d2(d2),
    .d1(d1),
    .c2(c2),
    .c1(c1),

    .output_pill_low(pill_low),       // 药片个位BCD
    .output_pill_high(pill_high),      // 药片十位 BCD
    .output_bottle_low(bottle_low),     // 瓶数个位 BCD
    .output_bottle_high(bottle_high),    // 瓶数十位 BCD

    .state(state),
    .disp_sel(disp_sel),

    .disp6(disp6),
    .disp5(disp5),
    .disp4(disp4),
    .disp3(disp3),
    .disp2(disp2)
);

pill_bottle_core u_bottle_core (
    .clk(clk),
    .clr(clr),
    .tick(tick),
    .run(run),
    .max_pill_low(max_pill_low),
    .max_pill_high(max_pill_high),
    .target_bottle_low(target_bottle_low),
    .target_bottle_high(target_bottle_high),
    .output_pill_low(pill_low),
    .output_pill_high(pill_high),
    .output_bottle_low(bottle_low),
    .output_bottle_high(bottle_high),
    .done(done),

    .config_set(config_set)
);

total_pills u_total_pills(
    .clk(clk),
    .clr(clr),      // 低电平有效复位
    .start(run),    // 计数使能 run

    .c1(c1),   // 个位 BCD
    .c2(c2),   // 十位 BCD
    .d1(d1),   // 百位 BCD
    .d2(d2)    // 千位 BCD
);
endmodule
