module testSoC();

`include "assert.v"
`include "alu.vh"
`define assertPc(value) if (uut.proc.pc !== value) begin $display("ASSERTION FAILED in %m: pc(%h) != value", uut.proc.pc); $finish(2); end
`define assertInstr(value) if (uut.proc.instruction !== value) begin $display("ASSERTION FAILED in %m: instruction(%h) != value", uut.proc.instruction); $finish(2); end
`define assertSecond(value) if (uut.proc.second !== value) begin $display("ASSERTION FAILED in %m: second(%h) != value", uut.proc.second); $finish(2); end
`define assertThird(value) if (uut.proc.third !== value) begin $display("ASSERTION FAILED in %m: third(%h) != value", uut.proc.third); $finish(2); end
`define assertFlags(value) if (uut.proc.flags !== value) begin $display("ASSERTION FAILED in %m: flags != value", uut.proc.flags); $finish(2); end
`define assertRegister(num, value) if (uut.proc.registers[num] !== value) begin $display("ASSERTION FAILED in %m: reg[%h] != value", num, uut.proc.registers[num]); $finish(2); end

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
