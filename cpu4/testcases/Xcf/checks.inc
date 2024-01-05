// scf
    @(negedge clk);
        `assert(uut.proc.pc, 0);
    @(negedge clk);
        `assert(uut.proc.pc, 1);
        `assert(uut.proc.instruction, 'hDF);
    @(negedge clk);
        // c
        `assert(uut.proc.flags, 'b1000_0000);

// rcf
    repeat (2) @(negedge clk);
        `assert(uut.proc.instruction, 'hCF);
    @(negedge clk);
        // nc
        `assert(uut.proc.flags, 'b0000_0000);

// ccf
    repeat (2) @(negedge clk);
        `assert(uut.proc.instruction, 'hEF);
    @(negedge clk);
        // nc
        `assert(uut.proc.flags, 'b1000_0000);


// ccf
    repeat (2) @(negedge clk);
        `assert(uut.proc.instruction, 'hEF);
    @(negedge clk);
        // nc
        `assert(uut.proc.flags, 'b0000_0000);


// jmp 0
    repeat (6) @(negedge clk);
        `assert(uut.proc.instruction, 'h8D);
        `assert(uut.proc.second,      'h00);
        `assert(uut.proc.third,       'h00);
    @(negedge clk);
        `assert(uut.proc.pc, 0);

    #3
