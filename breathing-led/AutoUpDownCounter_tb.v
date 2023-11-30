`include "AutoUpDownCounter.v"

module test();

    localparam bits = 4;

    reg              clk = 0;
    wire[bits - 1:0] out;

    AutoUpDownCounter #(bits) audc(
        .clk(clk),
        .out(out)
    );

    always
        #1 clk = ~clk;

    initial begin
        #100 $finish;
    end

    initial begin
        $dumpfile("AutoUpDownCounter.vcd");
        $dumpvars(0, test);
    end

endmodule
