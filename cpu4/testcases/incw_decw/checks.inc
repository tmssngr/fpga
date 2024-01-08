// ld 10, #1
    @(negedge clk);
        `assertPc(0);
    repeat (5) @(negedge clk);
        `assertInstr('hE6);
        `assert(uut.proc.second, 'h10);
        `assert(uut.proc.third, 'h01);
    @(negedge clk);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 0);
    @(negedge clk);
        `assert(uut.proc.registers['h10], 'h01);
        `assert(uut.proc.flags, 'b0000_0000);

// ld 11, #2
        `assertPc(3);
    repeat (5) @(negedge clk);
        `assertInstr('hE6);
        `assert(uut.proc.second, 'h11);
        `assert(uut.proc.third, 'h02);
    @(negedge clk);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 0);
    @(negedge clk);
        `assert(uut.proc.registers['h10], 'h01);
        `assert(uut.proc.registers['h11], 'h02);
        `assert(uut.proc.flags, 'b0000_0000);

// incw 10
        `assertPc(6);
    repeat (3) @(negedge clk);
        `assertInstr('hA0);
        `assert(uut.proc.second, 'h10);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assert(uut.proc.registers['h11], 'h03);
        `assert(uut.proc.flags, 'b0000_0000);
		// upper byte:
        `assert(uut.proc.aluMode, ALU1_INCW_UPPER_0);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assert(uut.proc.registers['h10], 'h01);
        `assert(uut.proc.flags, 'b0000_0000);

// decw 10
        `assertPc(8);
    repeat (3) @(negedge clk);
        `assertInstr('h80);
        `assert(uut.proc.second, 'h10);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_DEC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assert(uut.proc.registers['h11], 'h02);
        `assert(uut.proc.flags, 'b0000_0000);
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_INCW_UPPER_0);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assert(uut.proc.registers['h10], 'h01);
        `assert(uut.proc.flags, 'b0000_0000);

// ld 11, #7F
        `assertPc(10);
    repeat (5) @(negedge clk);
        `assertInstr('hE6);
        `assert(uut.proc.second, 'h11);
        `assert(uut.proc.third, 'h7F);
    @(negedge clk);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 0);
    @(negedge clk);
        `assert(uut.proc.registers['h10], 'h01);
        `assert(uut.proc.registers['h11], 'h7F);
        `assert(uut.proc.flags, 'b0000_0000);

// incw 10
        `assertPc(13);
    repeat (3) @(negedge clk);
        `assertInstr('hA0);
        `assert(uut.proc.second, 'h10);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assert(uut.proc.registers['h11], 'h80);
        // sv
        `assert(uut.proc.flags, 'b0011_0000);
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_INCW_UPPER_0);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assert(uut.proc.registers['h10], 'h01);
        `assert(uut.proc.flags, 'b0000_0000);

// decw 10
        `assertPc(15);
    repeat (3) @(negedge clk);
        `assertInstr('h80);
        `assert(uut.proc.second, 'h10);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_DEC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assert(uut.proc.registers['h11], 'h7F);
        // v
        `assert(uut.proc.flags, 'b0001_0000);
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_INCW_UPPER_0);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assert(uut.proc.registers['h10], 'h01);
        `assert(uut.proc.flags, 'b0000_0000);

// ld 11, #FF
        `assertPc(17);
    repeat (5) @(negedge clk);
        `assertInstr('hE6);
        `assert(uut.proc.second, 'h11);
        `assert(uut.proc.third, 'hFF);
    @(negedge clk);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 0);
    @(negedge clk);
        `assert(uut.proc.registers['h10], 'h01);
        `assert(uut.proc.registers['h11], 'hFF);

// incw 10
        `assertPc(20);
    repeat (3) @(negedge clk);
        `assertInstr('hA0);
        `assert(uut.proc.second, 'h10);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assert(uut.proc.registers['h11], 'h00);
        `assert(uut.proc.flags, 'b0100_0000);
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_INCW);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assert(uut.proc.registers['h10], 'h02);
        `assert(uut.proc.registers['h11], 'h00);
        `assert(uut.proc.flags, 'b0000_0000);

// decw 10
        `assertPc(22);
    repeat (3) @(negedge clk);
        `assertInstr('h80);
        `assert(uut.proc.second, 'h10);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_DEC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assert(uut.proc.registers['h11], 'hFF);
        // s
        `assert(uut.proc.flags, 'b0010_0000);
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_DECW);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assert(uut.proc.registers['h10], 'h01);
        `assert(uut.proc.flags, 'b0000_0000);

// ld 10, #FF
        `assertPc(24);
    repeat (5) @(negedge clk);
        `assertInstr('hE6);
        `assert(uut.proc.second, 'h10);
        `assert(uut.proc.third, 'hFF);
    @(negedge clk);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 0);
    @(negedge clk);
        `assert(uut.proc.registers['h10], 'hFF);
        `assert(uut.proc.registers['h11], 'hFF);

// incw 10
        `assertPc(27);
    repeat (3) @(negedge clk);
        `assertInstr('hA0);
        `assert(uut.proc.second, 'h10);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assert(uut.proc.registers['h11], 'h00);
        `assert(uut.proc.flags, 'b0100_0000);
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_INCW);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assert(uut.proc.registers['h10], 'h00);
        // z
        `assert(uut.proc.flags, 'b0100_0000);

// incw 10
        `assertPc(29);
    repeat (3) @(negedge clk);
        `assertInstr('hA0);
        `assert(uut.proc.second, 'h10);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_INC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assert(uut.proc.registers['h11], 'h01);
        `assert(uut.proc.flags, 'b0000_0000);
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_INCW_UPPER_0);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assert(uut.proc.registers['h10], 'h00);
        `assert(uut.proc.flags, 'b0000_0000);

// decw 10
        `assertPc(31);
    repeat (3) @(negedge clk);
        `assertInstr('h80);
        `assert(uut.proc.second, 'h10);
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
        `assert(uut.proc.registers['h10], 'h00);
        `assert(uut.proc.registers['h11], 'h00);
        // z
        `assert(uut.proc.flags, 'b0100_0000);

// decw 10
        `assertPc(33);
    repeat (3) @(negedge clk);
        `assertInstr('h80);
        `assert(uut.proc.second, 'h10);
        // lower byte:
    @(negedge clk);
        `assert(uut.proc.aluMode, ALU1_DEC);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assert(uut.proc.registers['h11], 'hFF);
        // s
        `assert(uut.proc.flags, 'b0010_0000);
        // upper byte:
        `assert(uut.proc.aluMode, ALU1_DECW);
        `assert(uut.proc.writeRegister, 1);
        `assert(uut.proc.writeFlags, 1);
    @(negedge clk);
        `assert(uut.proc.registers['h10], 'hFF);
        // s
        `assert(uut.proc.flags, 'b0010_0000);

// jmp 0
    repeat (5) @(negedge clk);
        `assertInstr('h8D);
        `assert(uut.proc.second,      'h00);
        `assert(uut.proc.third,       'h00);
    repeat (1) @(negedge clk);
        `assertPc(0);

    #3
