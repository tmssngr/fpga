module testSoC();

`include "assert.v"

    reg clk = 0;

    SoC uut(
        .clk(clk)
    );

    always
        #1 clk = ~clk;

    initial begin
        @(negedge clk);
        `assert(uut.proc.pc, 0);
        @(negedge clk);
        `assert(uut.proc.pc, 1);
        `assert(uut.proc.instruction, 'h0C);
        repeat (2) @(negedge clk);
        `assert(uut.proc.pc, 2);
        `assert(uut.proc.second, 'h0A);
        repeat (3) @(negedge clk);
        `assert(uut.proc.registers[0], 'h0A);

        `assert(uut.proc.pc, 3);
        `assert(uut.proc.instruction, 'h1C);
        repeat (2) @(negedge clk);
        `assert(uut.proc.pc, 4);
        `assert(uut.proc.second, 'h14);
        repeat (3) @(negedge clk);
        `assert(uut.proc.registers[1], 'h14);

        `assert(uut.proc.pc, 5);
        `assert(uut.proc.instruction, 'h02);
        repeat (2) @(negedge clk);
        `assert(uut.proc.pc, 6);
        `assert(uut.proc.second, 'h01);
        repeat (3) @(negedge clk);
        `assert(uut.proc.registers[0], 'h1E);
        `assert(uut.proc.registers[1], 'h14);

        `assert(uut.proc.pc, 7);
        `assert(uut.proc.instruction, 'hFF);
        repeat (3) @(negedge clk);

        `assert(uut.proc.pc, 8);
        `assert(uut.proc.instruction, 'h8D);
        repeat (2) @(negedge clk);
        `assert(uut.proc.pc, 9);
        `assert(uut.proc.second, 'h00);
        repeat (2) @(negedge clk);
        `assert(uut.proc.pc, 10);
        `assert(uut.proc.third, 'h02);
        repeat (2) @(negedge clk);
        `assert(uut.proc.pc, 2);

        #100
        $display("%m: SUCCESS");
        $finish(0);
    end

    initial begin
        $dumpfile("SoC.vcd");
        $dumpvars(0, uut);
    end
endmodule