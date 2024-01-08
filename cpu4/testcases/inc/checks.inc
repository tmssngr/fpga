// ld r0, #9
    @(negedge clk);
        `assertPc(0);
    @(negedge clk);
        `assertPc(1);
        `assertInstr('h0C);
    repeat (2) @(negedge clk);
        `assertPc(2);
        `assert(uut.proc.second, 'h09);
    repeat (3) @(negedge clk);
        `assert(uut.proc.registers[0], 'h09);

// inc 0
        `assertPc(3);
        `assertInstr('h20);
    repeat (2) @(negedge clk);
        `assertPc(4);
        `assert(uut.proc.second, 'h00);
    repeat (3) @(negedge clk);
        `assert(uut.proc.registers[0], 'h0A);
        `assert(uut.proc.flags, 'b0000_0000);

// ld r0, #7f
        `assertPc(5);
    repeat (2) @(negedge clk);
        `assertInstr('h0C);
        `assert(uut.proc.second, 'h7f);
    repeat (2) @(negedge clk);
        `assert(uut.proc.registers[0], 'h7f);

// inc 0
        `assertPc(6);
    repeat (3) @(negedge clk);
        `assertInstr('h20);
        `assert(uut.proc.second, 'h00);
    repeat (2) @(negedge clk);
        `assert(uut.proc.registers[0], 'h80);
        // sv
        `assert(uut.proc.flags, 'b0011_0000);

// ld r0, #FE
        `assertPc(8);
    repeat (3) @(negedge clk);
        `assertInstr('h0C);
        `assert(uut.proc.second, 'hFE);
    repeat (2) @(negedge clk);
        `assert(uut.proc.registers[0], 'hFE);

// inc 0
        `assertPc(10);
    repeat (3) @(negedge clk);
        `assertInstr('h20);
        `assert(uut.proc.second, 'h00);
    repeat (3) @(negedge clk);
        `assert(uut.proc.registers[0], 'hFF);
        // s
        `assert(uut.proc.flags, 'b0010_0000);

// inc 0
        `assertPc(13);
    repeat (3) @(negedge clk);
        `assertInstr('h20);
        `assert(uut.proc.second, 'h00);
    repeat (3) @(negedge clk);
        `assert(uut.proc.registers[0], 'h00);
        // z
        `assert(uut.proc.flags, 'b0100_0000);


// jmp 0
    repeat (4) @(negedge clk);
        `assertInstr('h8D);
        `assert(uut.proc.second,      'h00);
        `assert(uut.proc.third,       'h00);
    repeat (1) @(negedge clk);
        `assertPc(0);

    #3
