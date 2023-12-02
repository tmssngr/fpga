//`timescale 10ns/1ns
`include "assert.v"
`include "PWM.v"

module test();

    reg clk = 0;
    reg[3:0] brightness = 0;
    wire out;

    PWM pwm(
        .clk(clk),
        .brightness(brightness),
        .out(out)
    );

    always
        #1 clk = ~clk;

    initial begin
        `assert(out, 0);
        #1  `assert(out, 0);
        #30 `assert(out, 0);

        #1  `assert(out, 0);
        #1  `assert(out, 0);
        brightness = 1;
        #30 `assert(out, 0);

        #1  `assert(out, 1);
        #1  `assert(out, 1);
        #30 `assert(out, 0);

        #1  `assert(out, 1);
        brightness = 2;
        #1  `assert(out, 1);
        #30 `assert(out, 0);

        #1   `assert(out, 1);
        #3   `assert(out, 1);
        #1   `assert(out, 0);
        #27   `assert(out, 0);

        #1   `assert(out, 1);
        #3   `assert(out, 1);
        #1   `assert(out, 0);
        #27   `assert(out, 0);
        brightness = 15;

        #1   `assert(out, 1);
        #29  `assert(out, 1);
        #1   `assert(out, 0);
        #1   `assert(out, 0);

        #1   `assert(out, 1);
        brightness = 0;
        #29  `assert(out, 1);
        #1   `assert(out, 0);
        #1   `assert(out, 0);

        #1  `assert(out, 0);
        #1  `assert(out, 0);
        #30 `assert(out, 0);
        #10 $finish;
    end

    initial begin
        $dumpfile("PWM.vcd");
        $dumpvars(0, test);
    end

endmodule
