module pill_bottle_top (
    input clk,             // CP2, pin 57
    input clk_speaker,     // CP1, pin 56
    input clr,             // CLR#, pin 1
    input start,           // K1, pin 81
    input tick,            // CP3, pin 58
    input [1:0] set_sel,   // K3-K2, pins 79-80
    input inc,             // QD, pin 60
    input confirm,         // K0, pin 54
    input [1:0] disp_sel,  // K5-K4, pins 76-77

    output [3:0] disp6,
    output [3:0] disp5,
    output [3:0] disp4,
    output [3:0] disp3,
    output [3:0] disp2,
    output [6:0] disp1,
    output reg speaker
);

reg confirm_d;
always @(posedge clk or negedge clr) begin
    if (!clr) begin
        confirm_d <= 1'b0;
    end else begin
        confirm_d <= confirm;
    end
end
wire confirm_pulse = confirm ^ confirm_d;

wire [3:0] max_pill_low;
wire [3:0] max_pill_high;
wire [3:0] target_bottle_low;
wire [3:0] target_bottle_high;

wire config_valid;
wire warn;
wire config_set;
wire run;
wire done;
wire [1:0] state;

wire [3:0] pill_low;
wire [3:0] pill_high;
wire [3:0] bottle_low;
wire [3:0] bottle_high;

wire [3:0] d2;
wire [3:0] d1;
wire [3:0] c2;
wire [3:0] c1;

wire clk_out;
assign disp1 = 1'd0;

always @(*) begin
    if (state == 2'b10) begin
        speaker = clk;
    end else if (done == 1'b1) begin
        speaker = clk_out;
    end
end

spliter u_spliter (
    .clk(clk_speaker),
    .rst_n(clr),
    .clk_out(clk_out)
);

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

status_signal u_status_signal (
    .clk(clk),
    .clr(clr),
    .continue_en(start),
    .confirm_pulse(confirm_pulse),
    .done(done),
    .warn(warn),
    .config_valid(config_valid),
    .config_set(config_set),
    .run(run),
    .dis_state(state)
);

display_mux u_display_mux (
    .max_pill_low(max_pill_low),
    .max_pill_high(max_pill_high),
    .target_bottle_low(target_bottle_low),
    .target_bottle_high(target_bottle_high),
    .d2(d2),
    .d1(d1),
    .c2(c2),
    .c1(c1),
    .output_pill_low(pill_low),
    .output_pill_high(pill_high),
    .output_bottle_low(bottle_low),
    .output_bottle_high(bottle_high),
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

total_pills u_total_pills (
    .clk(tick),
    .clr(clr),
    .config_set(config_set),
    .start(run),
    .c1(c1),
    .c2(c2),
    .d1(d1),
    .d2(d2)
);

endmodule
