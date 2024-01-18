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
        `assertState(STATE_LDC_READ);
        `assert(uut.proc.dstRegister, 'h22);
        `assert(uut.proc.addr[15:8], 'h0);
    @(negedge clk);
        `assertState(STATE_READ_MEM1);
        `assert(uut.proc.dstRegister, 'h22);
        `assert(uut.proc.addr, 'h0B);
    @(negedge clk);
        `assertState(STATE_READ_MEM2);
        `assert(uut.proc.dstRegister, 'h22);
        `assert(uut.proc.addr, 'h0B);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h20, 'h00);
        `assertRegister(8'h21, 'h0B);
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
