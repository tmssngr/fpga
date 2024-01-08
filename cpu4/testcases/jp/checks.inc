// jp never, 0
    @(negedge clk);
        `assertPc(0);
    @(negedge clk);
        `assertPc(1);
        `assertInstr('h0D);
    repeat (2) @(negedge clk);
        `assertPc(2);
        `assertSecond('hFF);
    repeat (2) @(negedge clk);
        `assertPc(3);
        `assertThird('hFE);

// ld r0, #3
    repeat (3) @(negedge clk);
        `assertPc(4);
        `assertInstr('h0C);
    repeat (2) @(negedge clk);
        `assertPc(5);
        `assertSecond('h03);
    repeat (3) @(negedge clk);
        `assertRegister(0, 'h03);

// 5: add r0, r1
        `assertPc(6);
    repeat (4) @(negedge clk);
        `assertInstr('h06);
        `assertSecond('h00);
        `assertThird('hFF);
    repeat (3) @(negedge clk);
        `assertRegister(0, 'h02);
        // ch
        `assertFlags('b1000_0100);

// jp nz, 5
    repeat (4) @(negedge clk);
        `assertInstr('hED);
        `assertSecond('h00);
        `assertThird('h05);
    repeat (1) @(negedge clk);

// 5: add r0, r1
        `assertPc(5);
    repeat (6) @(negedge clk);
        `assertInstr('h06);
        `assertSecond('h00);
        `assertThird('hFF);
    repeat (2) @(negedge clk);
        `assertRegister(0, 'h01);
        // ch
        `assertFlags('b1000_0100);

// jp nz, 5
    repeat (5) @(negedge clk);
        `assertInstr('hED);
        `assertSecond('h00);
        `assertThird('h05);
    repeat (1) @(negedge clk);

// 5: add r0, r1
        `assertPc(5);
    repeat (6) @(negedge clk);
        `assertInstr('h06);
        `assertSecond('h00);
        `assertThird('hFF);
    repeat (2) @(negedge clk);
        `assertRegister(0, 'h00);
        // czh
        `assertFlags('b1100_0100);

// jp nz, 5
    repeat (5) @(negedge clk);
        `assertInstr('hED);
        `assertSecond('h00);
        `assertThird('h05);

// jmp 0
        `assertPc(11);
    repeat (7) @(negedge clk);
        `assertInstr('h8D);
        `assertSecond('h00);
        `assertThird('h00);
    @(negedge clk);
        `assertPc(0);

    #3
