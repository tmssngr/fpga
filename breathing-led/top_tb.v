`include "assert.v"
`include "top.v"
`timescale 10ns/1ns

module test();

    reg clk = 0;
    wire out;

    top uut(
        .clk(clk),
        .led(out)
    );

    always
        #1 clk = ~clk;

    initial begin
        #10000 $finish;
    end

    initial begin
        $dumpfile("top.vcd");
        $dumpvars(0, test);
    end

endmodule
