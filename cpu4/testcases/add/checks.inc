// ld r0, #9
    @(negedge clk);
        `assert(uut.proc.pc, 0);
    @(negedge clk);
        `assert(uut.proc.pc, 1);
        `assert(uut.proc.instruction, 'h0C);
    repeat (2) @(negedge clk);
        `assert(uut.proc.pc, 2);
        `assert(uut.proc.second, 'h09);
    repeat (3) @(negedge clk);
        `assert(uut.proc.registers[0], 'h09);

// ld r1, #1
        `assert(uut.proc.pc, 3);
        `assert(uut.proc.instruction, 'h1C);
    repeat (2) @(negedge clk);
        `assert(uut.proc.pc, 4);
        `assert(uut.proc.second, 'h01);
    repeat (3) @(negedge clk);
        `assert(uut.proc.registers[1], 'h01);

// add r0, r1
        `assert(uut.proc.pc, 5);
        `assert(uut.proc.instruction, 'h02);
    repeat (2) @(negedge clk);
        `assert(uut.proc.pc, 6);
        `assert(uut.proc.second, 'h01);
    repeat (3) @(negedge clk);
        `assert(uut.proc.registers[0], 'h0A);
        `assert(uut.proc.registers[1], 'h01);
        `assert(uut.proc.flags, 'b0000_0000);

// ld r1, #6
        `assert(uut.proc.pc, 7);
        `assert(uut.proc.instruction, 'h1C);
    repeat (2) @(negedge clk);
        `assert(uut.proc.pc, 8);
        `assert(uut.proc.second, 'h06);
    repeat (3) @(negedge clk);
        `assert(uut.proc.registers[1], 'h06);

// add r0, r1
        `assert(uut.proc.pc, 9);
        `assert(uut.proc.instruction, 'h02);
    repeat (2) @(negedge clk);
        `assert(uut.proc.pc, 10);
        `assert(uut.proc.second, 'h01);
    repeat (3) @(negedge clk);
        `assert(uut.proc.registers[0], 'h10);
        `assert(uut.proc.registers[1], 'h06);
        // h
        `assert(uut.proc.flags, 'b0000_0100);

// ld r1, #80
    repeat (5) @(negedge clk);
        `assert(uut.proc.registers[1], 'h80);

// add r0, r1
    repeat (2) @(negedge clk);
        `assert(uut.proc.instruction, 'h02);
        `assert(uut.proc.second,      'h01);
    repeat (3) @(negedge clk);
        `assert(uut.proc.registers[0], 'h90);
        // s
        `assert(uut.proc.flags, 'b0010_0000);

// ld r1, #70
    repeat (5) @(negedge clk);
        `assert(uut.proc.registers[1], 'h70);

// add r0, r1
    repeat (2) @(negedge clk);
        `assert(uut.proc.instruction, 'h02);
        `assert(uut.proc.second,      'h01);
    repeat (3) @(negedge clk);
        `assert(uut.proc.registers[0], 'h00);
        // cz
        `assert(uut.proc.flags, 'b1100_0000);

// ld r0, #FF
    repeat (5) @(negedge clk);
        `assert(uut.proc.registers[0], 'hFF);

// ld r1, #FF
    repeat (5) @(negedge clk);
        `assert(uut.proc.registers[1], 'hFF);

// add r1, r0
    repeat (5) @(negedge clk);
        `assert(uut.proc.registers[0], 'hFF);
        `assert(uut.proc.registers[1], 'hFE);
        // csh
        `assert(uut.proc.flags, 'b1010_0100);

// jmp 0
    repeat (4) @(negedge clk);
        `assert(uut.proc.instruction, 'h8D);
        `assert(uut.proc.second,      'h00);
        `assert(uut.proc.third,       'h00);
    repeat (2) @(negedge clk);
        `assert(uut.proc.pc, 0);

    #3
