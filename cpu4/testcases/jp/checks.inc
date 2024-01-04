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
        `assert(uut.proc.pc, 6);
        `assert(uut.proc.registers[0], 'h03);

// ld r1, #FF
        `assert(uut.proc.instruction, 'h1C);
    repeat (2) @(negedge clk);
        `assert(uut.proc.pc, 7);
        `assert(uut.proc.second, 'hFF);
    repeat (3) @(negedge clk);
        `assert(uut.proc.registers[1], 'hFF);

// 7: add r0, r1
        `assert(uut.proc.pc, 8);
        `assert(uut.proc.instruction, 'h02);
    repeat (2) @(negedge clk);
        `assert(uut.proc.pc, 9);
        `assert(uut.proc.second, 'h01);
    repeat (2) @(negedge clk);
        `assert(uut.proc.registers[0], 'h02);
        `assert(uut.proc.registers[1], 'hFF);
        // ch
        `assert(uut.proc.flags, 'b1000_0100);

// jp nz, 9
    repeat (2) @(negedge clk);
        `assert(uut.proc.pc, 10);
        `assert(uut.proc.instruction, 'hED);
    repeat (2) @(negedge clk);
        `assert(uut.proc.second, 'h00);
        `assert(uut.proc.pc, 11);
    repeat (2) @(negedge clk);
        `assert(uut.proc.third, 'h07);
        `assert(uut.proc.pc, 7);

// 7: add r0, r1
    repeat (2) @(negedge clk);
        `assert(uut.proc.pc, 8);
        `assert(uut.proc.instruction, 'h02);
    repeat (2) @(negedge clk);
        `assert(uut.proc.pc, 9);
        `assert(uut.proc.second, 'h01);
    repeat (2) @(negedge clk);
        `assert(uut.proc.registers[0], 'h01);
        `assert(uut.proc.registers[1], 'hFF);
        // ch
        `assert(uut.proc.flags, 'b1000_0100);

// jp nz, 9
    repeat (2) @(negedge clk);
        `assert(uut.proc.pc, 10);
        `assert(uut.proc.instruction, 'hED);
    repeat (2) @(negedge clk);
        `assert(uut.proc.second, 'h00);
        `assert(uut.proc.pc, 11);
    repeat (2) @(negedge clk);
        `assert(uut.proc.third, 'h07);
        `assert(uut.proc.pc, 7);

// 7: add r0, r1
    repeat (2) @(negedge clk);
        `assert(uut.proc.pc, 8);
        `assert(uut.proc.instruction, 'h02);
    repeat (2) @(negedge clk);
        `assert(uut.proc.pc, 9);
        `assert(uut.proc.second, 'h01);
    repeat (2) @(negedge clk);
        `assert(uut.proc.registers[0], 'h00);
        `assert(uut.proc.registers[1], 'hFF);
        // czh
        `assert(uut.proc.flags, 'b1100_0100);

// jp nz, 9 (not jumping)
    repeat (2) @(negedge clk);
        `assert(uut.proc.pc, 10);
        `assert(uut.proc.instruction, 'hED);
    repeat (2) @(negedge clk);
        `assert(uut.proc.second, 'h00);
        `assert(uut.proc.pc, 11);
    repeat (2) @(negedge clk);
        `assert(uut.proc.third, 'h07);
        `assert(uut.proc.pc, 12);

// jmp 0
    repeat (6) @(negedge clk);
        `assert(uut.proc.instruction, 'h8D);
        `assert(uut.proc.second,      'h00);
        `assert(uut.proc.third,       'h00);
    @(negedge clk);
        `assert(uut.proc.pc, 0);

    #3
