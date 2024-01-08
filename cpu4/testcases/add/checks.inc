// ld r0, #9
    @(negedge clk);
        `assertPc(0);
    @(negedge clk);
        `assertPc(1);
        `assertInstr('h0C);
    repeat (2) @(negedge clk);
        `assertPc(2);
        `assertSecond('h09);
    repeat (3) @(negedge clk);
        `assertRegister(0, 'h09);

// ld r1, #1
        `assertPc(3);
        `assertInstr('h1C);
    repeat (2) @(negedge clk);
        `assertPc(4);
        `assertSecond('h01);
    repeat (3) @(negedge clk);
        `assertRegister(1, 'h01);

// add r0, r1
        `assertPc(5);
        `assertInstr('h02);
    repeat (2) @(negedge clk);
        `assertPc(6);
        `assertSecond('h01);
    repeat (3) @(negedge clk);
        `assertRegister(0, 'h0A);
        `assertRegister(1, 'h01);
        `assertFlags('b0000_0000);

// ld r1, #6
        `assertPc(7);
        `assertInstr('h1C);
    repeat (2) @(negedge clk);
        `assertPc(8);
        `assertSecond('h06);
    repeat (3) @(negedge clk);
        `assertRegister(1, 'h06);

// add r0, r1
        `assertPc(9);
        `assertInstr('h02);
    repeat (2) @(negedge clk);
        `assertPc(10);
        `assertSecond('h01);
    repeat (3) @(negedge clk);
        `assertRegister(0, 'h10);
        `assertRegister(1, 'h06);
        // h
        `assertFlags('b0000_0100);

// ld r1, #80
    repeat (5) @(negedge clk);
        `assertRegister(1, 'h80);

// add r0, r1
    repeat (2) @(negedge clk);
        `assertInstr('h02);
        `assertSecond('h01);
    repeat (3) @(negedge clk);
        `assertRegister(0, 'h90);
        // s
        `assertFlags('b0010_0000);

// ld r1, #70
    repeat (5) @(negedge clk);
        `assertRegister(1, 'h70);

// add r0, r1
    repeat (2) @(negedge clk);
        `assertInstr('h02);
        `assertSecond('h01);
    repeat (3) @(negedge clk);
        `assertRegister(0, 'h00);
        // cz
        `assertFlags('b1100_0000);

// ld r0, #FF
    repeat (5) @(negedge clk);
        `assertRegister(0, 'hFF);

// ld r1, #FF
    repeat (5) @(negedge clk);
        `assertRegister(1, 'hFF);

// add r1, r0
    repeat (5) @(negedge clk);
        `assertRegister(0, 'hFF);
        `assertRegister(1, 'hFE);
        // csh
        `assertFlags('b1010_0100);

// jmp 0
    repeat (4) @(negedge clk);
        `assertInstr('h8D);
        `assertSecond('h00);
        `assertThird('h00);
    repeat (2) @(negedge clk);
        `assertPc(0);

    #3
