module testCPU();

    reg clk = 0;

    CPU uut(
        .clk(clk)
    );

    always
        #1 clk = ~clk;
    
    initial begin
        #100
        $display("%m: SUCCESS");
        $finish(0);
    end

    initial begin
        $dumpfile("CPU.vcd");
        $dumpvars(0, uut);
    end
endmodule