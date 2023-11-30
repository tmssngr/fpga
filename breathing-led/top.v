`include "PWM.v"
`include "Prescaler.v"
`include "AutoUpDownCounter.v"

module top (
    input  wire clk,
    output wire led
);

    wire[4:0] brightness;
    wire prescaledClk;

    PWM #(.BITS(5)) pwm(
        .clk(clk),
        .brightness(brightness),
        .out(led)
    );

    Prescaler #(.BITS(18)) ps(
        .clkIn(clk),
        .clkOut(prescaledClk)
    );

    AutoUpDownCounter #(.BITS(5)) audc(
        .clk(prescaledClk),
        .out(brightness)
    );

endmodule
