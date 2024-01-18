    @(negedge clk);
// srp #20
    repeat (3) @(negedge clk);
        `assertInstr('h31);
        `assertSecond('h20);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.proc.rp, 'h2);

// ld r0, #0
    repeat (3) @(negedge clk);
        `assertInstr('h0C);
        `assertSecond('h00);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'h00);

// ld r1, #B
    repeat (3) @(negedge clk);
        `assertInstr('h1C);
        `assertSecond('h0B);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'h00);
        `assertRegister('h21, 'h0B);

// ldc r2, Irr0
    repeat (3) @(negedge clk);
        `assertInstr('hC2);
        `assertSecond('h20);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.dstRegister, 'h22);
        `assert(uut.proc.addr[15:8], 'h0);
        `assertState(STATE_LDC_READ);
    @(negedge clk);
        `assert(uut.proc.dstRegister, 'h22);
        `assert(uut.proc.addr, 'h0B);
        `assertState(STATE_READ_MEM1);
    @(negedge clk);
        `assert(uut.proc.dstRegister, 'h22);
        `assert(uut.proc.addr, 'h0B);
        `assertState(STATE_READ_MEM2);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h20, 'h00);
        `assertRegister(8'h21, 'h0B);
        `assertRegister(8'h22, 'h0F);

// ld r0, #8
    repeat (3) @(negedge clk);
        `assertInstr('h0C);
        `assertSecond('h08);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'h08);

// ld r1, #12
    repeat (3) @(negedge clk);
        `assertInstr('h1C);
        `assertSecond('h12);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'h08);
        `assertRegister('h21, 'h12);

// ldc Irr0, r2
    repeat (3) @(negedge clk);
        `assertInstr('hD2);
        `assertSecond('h20);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.dstRegister, 'h21);
        `assert(uut.proc.srcRegister, 'h22);
        `assert(uut.proc.addr[15:8], 'h08);
        `assertState(STATE_LDC_WRITE1);
    @(negedge clk);
        `assert(uut.proc.dstRegister, 'h21);
        `assert(uut.proc.srcRegister, 'h22);
        `assert(uut.proc.addr, 'h0812);
        `assertState(STATE_LDC_WRITE2);
    @(negedge clk);
        `assert(uut.proc.dstRegister, 'h21);
        `assert(uut.proc.aluA, 'h0F);
        `assert(uut.proc.addr, 'h0812);
        `assertState(STATE_WRITE_MEM);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assert(uut.mem.memory['h812], 'h0F);
        `assertRegister(8'h20, 'h08);
        `assertRegister(8'h21, 'h12);
        `assertRegister(8'h22, 'h0F);

// jmp L0
    repeat (5) @(negedge clk);
        `assertInstr('h8D);
        `assertSecond('h00);
        `assertThird('h0C);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
        `assertPc('h000C);

    #3
