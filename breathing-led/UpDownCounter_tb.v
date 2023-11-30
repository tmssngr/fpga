`include "UpDownCounter.v"

module test();

    localparam bits = 4;

    reg       clk = 0;
    reg       dir = 0;
    wire[bits - 1:0] out;

    UpDownCounter #(
        .BITS(bits)
    ) udc (
        .clk(clk),
        .dir(dir),
        .out(out)
    );

    always
        #2 clk = ~clk;

    initial begin
        dir = 0;
        #80
        dir = 1;
        #80
        dir = 0;
        #20
        dir = 1;
        #30
        dir = 0;
        #80
        dir = 1;
        #100
        $finish;
    end

    initial begin
        $dumpfile("UpDownCounter.vcd");
        $dumpvars(0, test);
    end

endmodule
