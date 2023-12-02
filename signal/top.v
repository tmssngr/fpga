`include "PWM.v"
`include "Prescaler.v"
`include "UpDownCounter.v"

module Light #(
    parameter BITS = 4
) (
    input wire pwmClk,
    input wire changeClk,
    input wire on,
    output led
);

    wire[BITS - 1:0] brightness;
    PWM #(.BITS(BITS)) pwm(
        .clk(pwmClk),
        .brightness(brightness),
        .out(led)
    );

    UpDownCounter #(.BITS(BITS)) udc(
        .clk(changeClk),
        .dir(on),
        .out(brightness)
    );
endmodule

module top #(
    parameter BrightnessBits = 5,
    parameter ChangeBits = 17,
    parameter SignalBits = 28
) (
    input  wire clk,
    output wire[5:0] led
);
    wire changeClk;
    Prescaler #(.BITS(ChangeBits)) ps(
        .clkIn(clk),
        .clkOut(changeClk)
    );

    wire on;
    Light #(.BITS(BrightnessBits)) red (
        .pwmClk(clk),
        .changeClk(changeClk),
        .on(on),
        .led(led[0])
    );
    Light #(.BITS(BrightnessBits)) green (
        .pwmClk(clk),
        .changeClk(changeClk),
        .on(~on),
        .led(led[1])
    );

    Prescaler #(.BITS(SignalBits)) onPs(
        .clkIn(clk),
        .clkOut(on)
    );

    assign led[2] = 1;
    assign led[3] = 1;
    assign led[4] = 1;
    assign led[5] = 1;

endmodule
