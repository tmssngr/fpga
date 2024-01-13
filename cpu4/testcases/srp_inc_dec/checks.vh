// srp #10
    @(negedge clk);
        `assertPc(0);
    @(negedge clk);
        `assertPc(1);
        `assertInstr('h31);
    repeat (2) @(negedge clk);
        `assertPc(2);
        `assertSecond('h10);
    repeat (2) @(negedge clk);
        `assert(uut.proc.rp, 'h1);

// ld r0, #9
	@(negedge clk);
        `assertPc(3);
        `assertInstr('h0C);
    repeat (2) @(negedge clk);
        `assertPc(4);
        `assertSecond('h09);
    repeat (3) @(negedge clk);
        `assertRegister('h10, 'h09);

// inc 10
        `assertPc(5);
        `assertInstr('h20);
    repeat (2) @(negedge clk);
        `assertPc(6);
        `assertSecond('h10);
    repeat (3) @(negedge clk);
        `assertRegister('h10, 'h0A);
        `assertFlags('b0000_0000);

// dec 10
        `assertPc(7);
        `assertInstr('h00);
    repeat (2) @(negedge clk);
        `assertSecond('h10);
    repeat (3) @(negedge clk);
        `assertRegister('h10, 'h09);
        `assertFlags('b0000_0000);

// ld r0, #7f
        `assertPc(9);
    repeat (2) @(negedge clk);
        `assertInstr('h0C);
        `assertSecond('h7f);
    repeat (2) @(negedge clk);
        `assertRegister('h10, 'h7f);

// inc 10
        `assertPc(10);
    repeat (3) @(negedge clk);
        `assertInstr('h20);
        `assertSecond('h10);
    repeat (2) @(negedge clk);
        `assertRegister('h10, 'h80);
        // sv
        `assertFlags('b0011_0000);

// dec 10
        `assertPc(12);
    repeat (3) @(negedge clk);
        `assertInstr('h00);
        `assertSecond('h10);
    repeat (2) @(negedge clk);
        `assertRegister('h10, 'h7F);
        // v
        `assertFlags('b0001_0000);

// ld r0, #FE
        `assertPc(14);
    repeat (3) @(negedge clk);
        `assertInstr('h0C);
        `assertSecond('hFE);
    repeat (2) @(negedge clk);
        `assertRegister('h10, 'hFE);

// inc 10
        `assertPc(16);
    repeat (3) @(negedge clk);
        `assertInstr('h20);
        `assertSecond('h10);
    repeat (2) @(negedge clk);
        `assertRegister('h10, 'hFF);
        // s
        `assertFlags('b0010_0000);

// inc 10
        `assertPc(18);
    repeat (3) @(negedge clk);
        `assertInstr('h20);
        `assertSecond('h10);
    repeat (2) @(negedge clk);
        `assertRegister('h10, 'h00);
        // z
        `assertFlags('b0100_0000);

// dec 10
        `assertPc(20);
    repeat (3) @(negedge clk);
        `assertInstr('h00);
        `assertSecond('h10);
    repeat (2) @(negedge clk);
        `assertRegister('h10, 'hFF);
        // s
        `assertFlags('b0010_0000);

// dec 10
        `assertPc(22);
    repeat (3) @(negedge clk);
        `assertInstr('h00);
        `assertSecond('h10);
    repeat (2) @(negedge clk);
        `assertRegister('h10, 'hFE);
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
