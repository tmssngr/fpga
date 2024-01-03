integer memPC = 0;

task label;
    input [7:0] l;
    begin
        if (l != memPC) begin
            $display("%m expected label at %h", memPC);
            $finish(0);
        end
    end
endtask

task asm1;
    input [7:0] a;
    begin
        memory[memPC] = a;
        memPC = memPC + 1;
    end
endtask

task asm2;
    input [7:0] a;
    input [7:0] b;
    begin
        asm1(a);
        asm1(b);
    end
endtask

task asm3;
    input [7:0] a;
    input [7:0] b;
    input [7:0] c;
    begin
        asm1(a);
        asm1(b);
        asm1(c);
    end
endtask

task asm_nop;
    begin
        asm1('hFF);
    end
endtask

task asm_ld;
    input [3:0] dst;
    input [3:0] src;
    begin
        asm2({dst, 4'h8}, {4'hE, src});
    end
endtask

task asm_ldc;
    input [3:0] dst;
    input [7:0] src;
    begin
        asm2({dst, 4'hC}, src);
    end
endtask

task asm_add;
    input [3:0] dst;
    input [3:0] src;
    begin
        asm2(8'h02, {dst, src});
    end
endtask

task asm_adc;
    input [3:0] dst;
    input [3:0] src;
    begin
        asm2(8'h12, {dst, src});
    end
endtask

task asm_sub;
    input [3:0] dst;
    input [3:0] src;
    begin
        asm2(8'h22, {dst, src});
    end
endtask

task asm_sbc;
    input [3:0] dst;
    input [3:0] src;
    begin
        asm2(8'h32, {dst, src});
    end
endtask

task asm_or;
    input [3:0] dst;
    input [3:0] src;
    begin
        asm2(8'h42, {dst, src});
    end
endtask

task asm_and;
    input [3:0] dst;
    input [3:0] src;
    begin
        asm2(8'h52, {dst, src});
    end
endtask

task asm_tcm;
    input [3:0] dst;
    input [3:0] src;
    begin
        asm2(8'h62, {dst, src});
    end
endtask

task asm_tm;
    input [3:0] dst;
    input [3:0] src;
    begin
        asm2(8'h72, {dst, src});
    end
endtask

task asm_cp;
    input [3:0] dst;
    input [3:0] src;
    begin
        asm2(8'hA2, {dst, src});
    end
endtask

task asm_xor;
    input [3:0] dst;
    input [3:0] src;
    begin
        asm2(8'hB2, {dst, src});
    end
endtask

task asm_jump;
    input [15:0] addr;
    begin
        asm3(8'h8D, addr[15:8], addr[7:0]);
    end
endtask