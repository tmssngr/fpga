module testSoC();

`include "assert.v"
`include "alu.vh"
`define assertPc(value) if (uut.proc.pc !== value) begin $display("ASSERTION FAILED in %m: pc(%h) != value", uut.proc.pc); $finish(2); end
`define assertInstr(value) if (uut.proc.instruction !== value) begin $display("ASSERTION FAILED in %m: instruction(%h) != value", uut.proc.instruction); $finish(2); end

    reg clk = 0;

    SoC uut(
        .clk(clk)
    );

    always
        #1 clk = ~clk;

    initial begin
`include "checks.inc"
        $display("%m: SUCCESS");
        $finish(0);
    end

    initial begin
        $dumpfile("SoC.vcd");
        $dumpvars(0, uut);
    end
endmodule
