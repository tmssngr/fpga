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

// ld r1, #2
    repeat (3) @(negedge clk);
        `assertInstr('h1C);
        `assertSecond('h02);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'h00);
        `assertRegister('h21, 'h02);

// ld r2, #24
    repeat (3) @(negedge clk);
        `assertInstr('h2C);
        `assertSecond('h24);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister('h20, 'h00);
        `assertRegister('h21, 'h02);
        `assertRegister('h22, 'h24);

// ldci Ir2, Irr0
    repeat (3) @(negedge clk);
        `assertInstr('hC3);
        `assertSecond('h20);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.dstRegister, 'h24);
        `assertState(STATE_LDC_READ1);
    @(negedge clk);
        `assert(uut.proc.addr[15:8], 'h0);
        `assertState(STATE_LDC_READ2);
    @(negedge clk);
        `assert(uut.proc.addr, 16'h0002);
        `assertState(STATE_READ_MEM1);
    @(negedge clk);
        `assertRom(16'h0002, 8'h08);
        `assertState(STATE_READ_MEM2);
    @(negedge clk);
        `assert(uut.proc.aluA, 8'h08);
        `assert(uut.proc.aluMode, ALU1_LD);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_INC_R_RR1);
    @(negedge clk);
        `assertRegister(8'h24, 8'h08);

        `assert(uut.proc.aluA, 8'h24);
        `assert(uut.proc.dstRegister, 8'h22);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_INC_R_RR2);
    @(negedge clk);
        `assertRegister(8'h22, 8'h25);

        `assert(uut.proc.aluA, 8'h02);
        `assert(uut.proc.dstRegister, 8'h21);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_INC_R_RR3);
    @(negedge clk);
        `assertRegister(8'h21, 8'h03);

        `assert(uut.proc.aluA, 8'h00);
        `assert(uut.proc.dstRegister, 8'h20);
        `assert(uut.proc.aluMode, ALU1_INCW_UPPER_0);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h20, 8'h00);

// ldci Ir2, Irr0
    repeat (3) @(negedge clk);
        `assertInstr('hC3);
        `assertSecond('h20);
        `assertState(STATE_DECODE);
    @(negedge clk);
        `assert(uut.proc.dstRegister, 'h25);
        `assertState(STATE_LDC_READ1);
    @(negedge clk);
        `assert(uut.proc.addr[15:8], 'h0);
        `assertState(STATE_LDC_READ2);
    @(negedge clk);
        `assert(uut.proc.addr, 16'h0003);
        `assertState(STATE_READ_MEM1);
    @(negedge clk);
        `assertRom(16'h0003, 8'h03);
        `assertState(STATE_READ_MEM2);
    @(negedge clk);
        `assert(uut.proc.aluA, 8'h03);
        `assert(uut.proc.aluMode, ALU1_LD);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_INC_R_RR1);
    @(negedge clk);
        `assertRegister(8'h25, 8'h03);

        `assert(uut.proc.aluA, 8'h25);
        `assert(uut.proc.dstRegister, 8'h22);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_INC_R_RR2);
    @(negedge clk);
        `assertRegister(8'h22, 8'h26);

        `assert(uut.proc.aluA, 8'h03);
        `assert(uut.proc.dstRegister, 8'h21);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_INC_R_RR3);
    @(negedge clk);
        `assertRegister(8'h21, 8'h04);

        `assert(uut.proc.aluA, 8'h00);
        `assert(uut.proc.dstRegister, 8'h20);
        `assert(uut.proc.aluMode, ALU1_INCW_UPPER_0);
        `assert(uut.proc.writeRegister, 1);
        `assertState(STATE_FETCH_INSTR);
    @(negedge clk);
        `assertRegister(8'h20, 8'h00);

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
