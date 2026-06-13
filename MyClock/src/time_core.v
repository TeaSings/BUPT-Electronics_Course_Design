module time_core (
    input clk,
    input clr,
    input tick,
    input set_en,
    input [3:0] set_low,
    input [3:0] set_high,

    //与设时系统接入
    input time_load_en,
    input [3:0] time_load_min_low,
    input [3:0] time_load_min_high,
    input [3:0] time_load_hour_low,
    input [3:0] time_load_hour_high,

    //sec_low的bcd码，便于设时系统接收信号
    output [3:0] bcd_sec_low,
    output [6:0] seg_sec_low,
    output [3:0] bcd_sec_high,
    output [3:0] bcd_min_low,
    output [3:0] bcd_min_high,
    output [3:0] bcd_hour_low,
    output [3:0] bcd_hour_high
);
reg tick_d;
always @(posedge clk or negedge clr) begin
    if (!clr) begin
        tick_d <= 1'b0;
    end else begin
        tick_d <= tick;
    end
end
wire tick_pluse = tick & ~tick_d;

//！！考虑改成reg
wire [3:0] sec_low;
wire [3:0] sec_high;

wire [3:0] min_low;
wire [3:0] min_high;

wire [3:0] hour_low;
wire [3:0] hour_high;

wire sec_wrap = (sec_high == 4'd5) && (sec_low == 4'd9) && tick_pluse;
wire min_wrap = sec_wrap && (min_high == 4'd5) && (min_low == 4'd9) && tick_pluse;

second_counter u_second (
    .clk(clk),
    .clr(clr),
    .tick(tick_pluse),
    .set_en(1'd0),
    .set_low(4'd0),
    .set_high(4'd0),
    .output_low(sec_low),
    .output_high(sec_high)
);

second_counter u_minute (
    .clk(clk),
    .clr(clr),
    .tick(sec_wrap),
    .set_en(time_load_en),
    .set_low(time_load_min_low),
    .set_high(time_load_min_high),
    .output_low(min_low),
    .output_high(min_high)
);

hour_counter u_hour (
    .clk(clk),
    .clr(clr),
    .tick(min_wrap),
    .set_en(time_load_en),
    .set_low(time_load_hour_low),
    .set_high(time_load_hour_high),
    .output_low(hour_low),
    .output_high(hour_high)
);

bcd_to_7_seg u_seg_sec_low (
    .led(sec_low),
    .light(seg_sec_low)
);

assign bcd_sec_low = sec_low;
assign bcd_sec_high = sec_high;
assign bcd_min_low = min_low;
assign bcd_min_high = min_high;
assign bcd_hour_low = hour_low;
assign bcd_hour_high = hour_high;

endmodule
