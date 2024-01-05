// jp never, 0
    @(negedge clk);
        `assert(uut.proc.pc, 0);
    @(negedge clk);
        `assert(uut.proc.pc, 1);
        `assert(uut.proc.instruction, 'h0D);
    repeat (2) @(negedge clk);
        `assert(uut.proc.pc, 2);
        `assert(uut.proc.second, 'hFF);
    repeat (2) @(negedge clk);
        `assert(uut.proc.pc, 3);
        `assert(uut.proc.third, 'hFE);

// ld r0, #3
    repeat (3) @(negedge clk);
        `assert(uut.proc.pc, 4);
        `assert(uut.proc.instruction, 'h0C);
    repeat (2) @(negedge clk);
        `assert(uut.proc.pc, 5);
        `assert(uut.proc.second, 'h03);
    repeat (3) @(negedge clk);
        `assert(uut.proc.registers[0], 'h03);

// 5: add r0, r1
        `assert(uut.proc.pc, 6);
    repeat (4) @(negedge clk);
        `assert(uut.proc.instruction, 'h06);
        `assert(uut.proc.second,      'h00);
        `assert(uut.proc.third,       'hFF);
    repeat (3) @(negedge clk);
        `assert(uut.proc.registers[0], 'h02);
        // ch
        `assert(uut.proc.flags, 'b1000_0100);

// jp nz, 5
    repeat (4) @(negedge clk);
        `assert(uut.proc.instruction, 'hED);
        `assert(uut.proc.second,      'h00);
        `assert(uut.proc.third,       'h05);
    repeat (1) @(negedge clk);

// 5: add r0, r1
        `assert(uut.proc.pc, 5);
    repeat (6) @(negedge clk);
        `assert(uut.proc.instruction, 'h06);
        `assert(uut.proc.second,      'h00);
        `assert(uut.proc.third,       'hFF);
    repeat (2) @(negedge clk);
        `assert(uut.proc.registers[0], 'h01);
        // ch
        `assert(uut.proc.flags, 'b1000_0100);

// jp nz, 5
    repeat (5) @(negedge clk);
        `assert(uut.proc.instruction, 'hED);
        `assert(uut.proc.second,      'h00);
        `assert(uut.proc.third,       'h05);
    repeat (1) @(negedge clk);

// 5: add r0, r1
        `assert(uut.proc.pc, 5);
    repeat (6) @(negedge clk);
        `assert(uut.proc.instruction, 'h06);
        `assert(uut.proc.second,      'h00);
        `assert(uut.proc.third,       'hFF);
    repeat (2) @(negedge clk);
        `assert(uut.proc.registers[0], 'h00);
        // czh
        `assert(uut.proc.flags, 'b1100_0100);

// jp nz, 5
    repeat (5) @(negedge clk);
        `assert(uut.proc.instruction, 'hED);
        `assert(uut.proc.second,      'h00);
        `assert(uut.proc.third,       'h05);

// jmp 0
        `assert(uut.proc.pc, 11);
    repeat (7) @(negedge clk);
        `assert(uut.proc.instruction, 'h8D);
        `assert(uut.proc.second,      'h00);
        `assert(uut.proc.third,       'h00);
    @(negedge clk);
        `assert(uut.proc.pc, 0);

    #3
