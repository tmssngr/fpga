// scf
    @(negedge clk);
        `assertPc(0);
    @(negedge clk);
        `assertPc(1);
        `assert(uut.proc.instruction, 'hDF);
    repeat (2) @(negedge clk);
        // c
        `assert(uut.proc.flags, 'b1000_0000);

// rcf
    repeat (2) @(negedge clk);
        `assert(uut.proc.instruction, 'hCF);
    repeat (2) @(negedge clk);
        // nc
        `assert(uut.proc.flags, 'b0000_0000);

// ccf
    repeat (2) @(negedge clk);
        `assert(uut.proc.instruction, 'hEF);
    repeat (2) @(negedge clk);
        // nc
        `assert(uut.proc.flags, 'b1000_0000);


// ccf
    repeat (2) @(negedge clk);
        `assert(uut.proc.instruction, 'hEF);
    repeat (2) @(negedge clk);
        // nc
        `assert(uut.proc.flags, 'b0000_0000);


// jmp 0
    repeat (6) @(negedge clk);
        `assert(uut.proc.instruction, 'h8D);
        `assert(uut.proc.second,      'h00);
        `assert(uut.proc.third,       'h00);
    @(negedge clk);
        `assertPc(0);

    #3
