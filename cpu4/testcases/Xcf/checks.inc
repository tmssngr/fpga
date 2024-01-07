// scf
    @(negedge clk);
        `assertPc(0);
    @(negedge clk);
        `assertPc(1);
        `assertInstr('hDF);
    repeat (2) @(negedge clk);
        // c
        `assert(uut.proc.flags, 'b1000_0000);

// rcf
    repeat (2) @(negedge clk);
        `assertInstr('hCF);
    repeat (2) @(negedge clk);
        // nc
        `assert(uut.proc.flags, 'b0000_0000);

// ccf
    repeat (2) @(negedge clk);
        `assertInstr('hEF);
    repeat (2) @(negedge clk);
        // nc
        `assert(uut.proc.flags, 'b1000_0000);


// ccf
    repeat (2) @(negedge clk);
        `assertInstr('hEF);
    repeat (2) @(negedge clk);
        // nc
        `assert(uut.proc.flags, 'b0000_0000);


// jmp 0
    repeat (6) @(negedge clk);
        `assertInstr('h8D);
        `assert(uut.proc.second,      'h00);
        `assert(uut.proc.third,       'h00);
    @(negedge clk);
        `assertPc(0);

    #3
