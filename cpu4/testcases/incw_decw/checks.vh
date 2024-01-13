// ld 10, #1
    @(negedge clk);
        `assertPc(0);
    repeat (5) @(negedge clk);
        `assertInstr('hE6);
        `assertSecond('h10);
        `assertThird('h01);
    @(negedge clk);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 0);
    @(negedge clk);
        `assertRegister('h10, 'h01);
        `assertFlags('b0000_0000);

// ld 11, #2
        `assertPc(3);
    repeat (5) @(negedge clk);
        `assertInstr('hE6);
        `assertSecond('h11);
        `assertThird('h02);
    @(negedge clk);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 0);
    @(negedge clk);
        `assertRegister('h10, 'h01);
        `assertRegister('h11, 'h02);
        `assertFlags('b0000_0000);

// incw 10
        `assertPc(6);
    repeat (3) @(negedge clk);
        `assertInstr('hA0);
        `assertSecond('h10);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h11, 'h03);
        `assertFlags('b0000_0000);
		// upper byte:
        `assert(uut.proc.aluMode, ALU1_INCW_UPPER_0);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h10, 'h01);
        `assertFlags('b0000_0000);

// decw 10
        `assertPc(8);
    repeat (3) @(negedge clk);
        `assertInstr('h80);
        `assertSecond('h10);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_DEC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h11, 'h02);
        `assertFlags('b0000_0000);
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_INCW_UPPER_0);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h10, 'h01);
        `assertFlags('b0000_0000);

// ld 11, #7F
        `assertPc(10);
    repeat (5) @(negedge clk);
        `assertInstr('hE6);
        `assertSecond('h11);
        `assertThird('h7F);
    @(negedge clk);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 0);
    @(negedge clk);
        `assertRegister('h10, 'h01);
        `assertRegister('h11, 'h7F);
        `assertFlags('b0000_0000);

// incw 10
        `assertPc(13);
    repeat (3) @(negedge clk);
        `assertInstr('hA0);
        `assertSecond('h10);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h11, 'h80);
        // sv
        `assertFlags('b0011_0000);
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_INCW_UPPER_0);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h10, 'h01);
        `assertFlags('b0000_0000);

// decw 10
        `assertPc(15);
    repeat (3) @(negedge clk);
        `assertInstr('h80);
        `assertSecond('h10);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_DEC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h11, 'h7F);
        // v
        `assertFlags('b0001_0000);
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_INCW_UPPER_0);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h10, 'h01);
        `assertFlags('b0000_0000);

// ld 11, #FF
        `assertPc(17);
    repeat (5) @(negedge clk);
        `assertInstr('hE6);
        `assertSecond('h11);
        `assertThird('hFF);
    @(negedge clk);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 0);
    @(negedge clk);
        `assertRegister('h10, 'h01);
        `assertRegister('h11, 'hFF);

// incw 10
        `assertPc(20);
    repeat (3) @(negedge clk);
        `assertInstr('hA0);
        `assertSecond('h10);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h11, 'h00);
        `assertFlags('b0100_0000);
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_INCW);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h10, 'h02);
        `assertRegister('h11, 'h00);
        `assertFlags('b0000_0000);

// decw 10
        `assertPc(22);
    repeat (3) @(negedge clk);
        `assertInstr('h80);
        `assertSecond('h10);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_DEC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h11, 'hFF);
        // s
        `assertFlags('b0010_0000);
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_DECW);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h10, 'h01);
        `assertFlags('b0000_0000);

// ld 10, #FF
        `assertPc(24);
    repeat (5) @(negedge clk);
        `assertInstr('hE6);
        `assertSecond('h10);
        `assertThird('hFF);
    @(negedge clk);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 0);
    @(negedge clk);
        `assertRegister('h10, 'hFF);
        `assertRegister('h11, 'hFF);

// incw 10
        `assertPc(27);
    repeat (3) @(negedge clk);
        `assertInstr('hA0);
        `assertSecond('h10);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h11, 'h00);
        `assertFlags('b0100_0000);
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_INCW);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h10, 'h00);
        // z
        `assertFlags('b0100_0000);

// incw 10
        `assertPc(29);
    repeat (3) @(negedge clk);
        `assertInstr('hA0);
        `assertSecond('h10);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h11, 'h01);
        `assertFlags('b0000_0000);
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_INCW_UPPER_0);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h10, 'h00);
        `assertFlags('b0000_0000);

// decw 10
        `assertPc(31);
    repeat (3) @(negedge clk);
        `assertInstr('h80);
        `assertSecond('h10);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_DEC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_INCW_UPPER_0);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h10, 'h00);
        `assertRegister('h11, 'h00);
        // z
        `assertFlags('b0100_0000);

// decw 10
        `assertPc(33);
    repeat (3) @(negedge clk);
        `assertInstr('h80);
        `assertSecond('h10);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_DEC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h11, 'hFF);
        // s
        `assertFlags('b0010_0000);
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_DECW);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assertRegister('h10, 'hFF);
        // s
        `assertFlags('b0010_0000);

// jmp 0
    repeat (5) @(negedge clk);
        `assertInstr('h8D);
        `assertSecond('h00);
        `assertThird('h00);
    repeat (1) @(negedge clk);
        `assertPc(0);

    #3
