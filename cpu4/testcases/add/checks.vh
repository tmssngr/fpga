// ld r0, #9
    @(negedge clk);
        `assertPc(12);
        `assertState(STATE_READ_INSTR);
    repeat (3) @(negedge clk);
        `assertInstr('h0C);
        `assertSecond('h09);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.dstRegister, 'h00);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(0, 'h09);

// ld r1, #1
    repeat (3) @(negedge clk);
        `assertInstr('h1C);
        `assertSecond('h01);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.dstRegister, 'h01);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(1, 'h01);

// add r0, r1
    repeat (3) @(negedge clk);
        `assertInstr('h02);
        `assertSecond('h01);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assert(uut.proc.dstRegister, 'h00);
        `assert(uut.proc.aluMode, ALU2_ADD);
        `assert(uut.proc.aluA, 'h09);
        `assert(uut.proc.aluB, 'h01);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(0, 'h0A);
        `assertRegister(1, 'h01);
        `assertFlags('b0000_0000);

// ld r1, #6
    repeat (3) @(negedge clk);
        `assertInstr('h1C);
        `assertSecond('h06);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.dstRegister, 'h01);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(1, 'h06);

// add r0, r1
    repeat (3) @(negedge clk);
        `assertInstr('h02);
        `assertSecond('h01);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assert(uut.proc.dstRegister, 'h00);
        `assert(uut.proc.aluMode, ALU2_ADD);
        `assert(uut.proc.aluA, 'h0A);
        `assert(uut.proc.aluB, 'h06);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(0, 'h10);
        `assertRegister(1, 'h06);
        // h
        `assertFlags('b0000_0100);

// ld r1, #80
    repeat (3) @(negedge clk);
        `assertInstr('h1C);
        `assertSecond('h80);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(1, 'h80);

// add r0, r1
    repeat (3) @(negedge clk);
        `assertInstr('h02);
        `assertSecond('h01);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(0, 'h90);
        // s
        `assertFlags('b0010_0000);

// ld r1, #70
    repeat (3) @(negedge clk);
        `assertInstr('h1C);
        `assertSecond('h70);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(1, 'h70);

// add r0, r1
    repeat (3) @(negedge clk);
        `assertInstr('h02);
        `assertSecond('h01);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(0, 'h00);
        // cz
        `assertFlags('b1100_0000);

// ld r0, #FF
    repeat (3) @(negedge clk);
        `assertInstr('h0C);
        `assertSecond('hFF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(0, 'hFF);

// ld r1, #FF
    repeat (3) @(negedge clk);
        `assertInstr('h1C);
        `assertSecond('hFF);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(1, 'hFF);

// add r1, r0
    repeat (3) @(negedge clk);
        `assertInstr('h02);
        `assertSecond('h10);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_ALU2_OP);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(0, 'hFF);
        `assertRegister(1, 'hFE);
        // csh
        `assertFlags('b1010_0100);

// jmp L0
    repeat (5) @(negedge clk);
        `assertInstr('h8D);
        `assertSecond('h00);
        `assertThird('h0C);
    repeat (2) @(negedge clk);
        `assertPc('h000C);

    #3
