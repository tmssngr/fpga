`ifndef PWM
`define PWM 1

module PWM #(
    parameter BITS = 4
) (
    input              clk,
    input [BITS - 1:0] brightness,
    output             out
);
    reg[BITS - 1:0] counter = 0;
    reg[BITS - 1:0] compareValue = 0;

    always @(posedge clk) begin
        counter <= counter + 1;
    end

    always @(posedge clk) begin
        if (counter == {BITS{1'b1}}) begin
            compareValue <= brightness;
        end
    end

    assign out = counter < compareValue;
endmodule

`endif