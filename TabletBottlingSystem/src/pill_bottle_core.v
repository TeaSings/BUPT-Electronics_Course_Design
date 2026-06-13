module pill_bottle_core (
    input clk,
    input clr,
    input tick,
    input run,
    input config_set,

    input [3:0] max_pill_low,
    input [3:0] max_pill_high,
    input [3:0] target_bottle_low,
    input [3:0] target_bottle_high,

    output [3:0] output_pill_low,
    output [3:0] output_pill_high,
    output [3:0] output_bottle_low,
    output [3:0] output_bottle_high,
    output done
);

wire full_bottle_pulse;
wire tick_pulse;
wire count_en;
reg tick_d;
always @(posedge clk or negedge clr) begin
    if (!clr) begin
        tick_d <= 1'b0;
    end else begin
        tick_d <= tick;
    end
end
assign tick_pulse = tick & ~tick_d;
assign count_en = tick_pulse & run;

pill_counter u_pill_counter (
    .clk(clk),
    .clr(clr),
    .count_en(count_en),
    .max_low(max_pill_low),
    .max_high(max_pill_high),
    .full_bottle_pulse(full_bottle_pulse),
    .output_low(output_pill_low),
    .output_high(output_pill_high),

    .config_set(config_set)
);

bottle_counter u_bottle_counter (
    .clk(clk),
    .clr(clr),
    .count_en(count_en),
    .inc_bottle(full_bottle_pulse),
    .target_low(target_bottle_low),
    .target_high(target_bottle_high),
    .output_low(output_bottle_low),
    .output_high(output_bottle_high),
    .done(done),

    .config_set(config_set)
);

endmodule
