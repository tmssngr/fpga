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

// inc 0
        `assertPc(3);
        `assertInstr('h20);
    repeat (2) @(negedge clk);
        `assertPc(4);
        `assertSecond('h00);
    repeat (3) @(negedge clk);
        `assertRegister(0, 'h0A);
        `assertFlags('b0000_0000);

// ld r0, #7f
        `assertPc(5);
    repeat (2) @(negedge clk);
        `assertInstr('h0C);
        `assertSecond('h7f);
    repeat (2) @(negedge clk);
        `assertRegister(0, 'h7f);

// inc 0
        `assertPc(6);
    repeat (3) @(negedge clk);
        `assertInstr('h20);
        `assertSecond('h00);
    repeat (2) @(negedge clk);
        `assertRegister(0, 'h80);
        // sv
        `assertFlags('b0011_0000);

// ld r0, #FE
        `assertPc(8);
    repeat (3) @(negedge clk);
        `assertInstr('h0C);
        `assertSecond('hFE);
    repeat (2) @(negedge clk);
        `assertRegister(0, 'hFE);

// inc 0
        `assertPc(10);
    repeat (3) @(negedge clk);
        `assertInstr('h20);
        `assertSecond('h00);
    repeat (3) @(negedge clk);
        `assertRegister(0, 'hFF);
        // s
        `assertFlags('b0010_0000);

// inc 0
        `assertPc(13);
    repeat (3) @(negedge clk);
        `assertInstr('h20);
        `assertSecond('h00);
    repeat (3) @(negedge clk);
        `assertRegister(0, 'h00);
        // z
        `assertFlags('b0100_0000);


// jmp 0
    repeat (4) @(negedge clk);
        `assertInstr('h8D);
        `assertSecond('h00);
        `assertThird('h00);
    repeat (1) @(negedge clk);
        `assertPc(0);

    #3
