module config_core (
    input clk,
    input clr,
    input start_setting,
    input [1:0] set_sel,
    input inc,  //qd
    input confirm,

    output reg [3:0] max_pill_low,
    output reg [3:0] max_pill_high,
    output reg [3:0] target_bottle_low,
    output reg [3:0] target_bottle_high,
    output reg config_valid,
    output reg warn
);

reg inc_d;
wire inc_pulse;
wire setting_valid;
assign inc_pulse = inc & ~inc_d;
assign setting_valid = ((max_pill_high != 4'd0) || (max_pill_low != 4'd0)) && ((target_bottle_high != 4'd0) || (target_bottle_low != 4'd0));

always @(posedge clk or negedge clr) begin
    if (!clr) begin
        max_pill_low <= 4'd1;
        max_pill_high <= 4'd0;
        target_bottle_low <= 4'd1;
        target_bottle_high <= 4'd0;
        config_valid <= 1'b0;
        warn <= 1'b0;
        inc_d <= 1'b0;
    end else begin
        inc_d <= inc;

        if (start_setting && inc_pulse) begin
            config_valid <= 1'b0;
            warn <= 1'b0;

            case (set_sel)
                2'b00: max_pill_low <= (max_pill_low == 4'd9) ? 4'd0 : max_pill_low + 1'b1;
                2'b01: max_pill_high <= (max_pill_high == 4'd9) ? 4'd0 : max_pill_high + 1'b1;
                2'b10: target_bottle_low <= (target_bottle_low == 4'd9) ? 4'd0 : target_bottle_low + 1'b1;
                2'b11: target_bottle_high <= (target_bottle_high == 4'd9) ? 4'd0 : target_bottle_high + 1'b1;
                default: ;
            endcase
        end else if (start_setting && confirm) begin
            if (setting_valid) begin
                config_valid <= 1'b1;
                warn <= 1'b0;
            end else begin
                config_valid <= 1'b0;
                warn <= 1'b1;
            end
        end
    end
end

endmodule
