// jr never, 0
    @(negedge clk);
        `assertPc(0);
    @(negedge clk);
        `assertPc(1);
        `assertInstr('h0B);
    repeat (2) @(negedge clk);
        `assertPc(2);
        `assertSecond('hFE);

// ld r0, #3
    repeat (3) @(negedge clk);
        `assertPc(3);
        `assertInstr('h0C);
    repeat (2) @(negedge clk);
        `assertPc(4);
        `assertSecond('h03);
    repeat (3) @(negedge clk);
        `assertRegister(0, 'h03);

// 4: add r0, r1
        `assertPc(5);
    repeat (4) @(negedge clk);
        `assertInstr('h06);
        `assertSecond('h00);
        `assertThird('hFF);
    repeat (3) @(negedge clk);
        `assertRegister(0, 'h02);
        // ch
        `assertFlags('b1000_0100);

// jr nz, L1
    repeat (2) @(negedge clk);
        `assertInstr('hEB);
        `assertSecond('hFB);
    repeat (1) @(negedge clk);

// 4: add r0, r1
        `assertPc(4);
    repeat (6) @(negedge clk);
        `assertInstr('h06);
        `assertSecond('h00);
        `assertThird('hFF);
    repeat (2) @(negedge clk);
        `assertRegister(0, 'h01);
        // ch
        `assertFlags('b1000_0100);

// jr nz, L1
    repeat (3) @(negedge clk);
        `assertInstr('hEB);
        `assertSecond('hFB);
    repeat (1) @(negedge clk);

// 4: add r0, r1
        `assertPc(4);
    repeat (6) @(negedge clk);
        `assertInstr('h06);
        `assertSecond('h00);
        `assertThird('hFF);
    repeat (2) @(negedge clk);
        `assertRegister(0, 'h00);
        // czh
        `assertFlags('b1100_0100);

// jr nz, L1
    repeat (3) @(negedge clk);
        `assertInstr('hEB);
        `assertSecond('hFB);

// jr 0
        `assertPc(9);
    repeat (5) @(negedge clk);
        `assertInstr('h8B);
        `assertSecond('hF5);
    @(negedge clk);
        `assertPc(0);

    #3
