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

task asm_rcf;
    begin
        asm1('hCF);
    end
endtask

task asm_scf;
    begin
        asm1('hDF);
    end
endtask

task asm_ccf;
    begin
        asm1('hEF);
    end
endtask

task asm_ld;
    input [3:0] dst;
    input [3:0] src;
    begin
        asm2({dst, 4'h8}, {4'hE, src});
    end
endtask

task asm_ld_r_IM;
    input [3:0] dst;
    input [7:0] src;
    begin
        asm2({dst, 4'hC}, src);
    end
endtask

task asm_ld_R_IM;
    input [7:0] dst;
    input [7:0] src;
    begin
        asm3(8'hE6, dst, src);
    end
endtask

task asm_add_r_r;
    input [3:0] dst;
    input [3:0] src;
    begin
        asm2(8'h02, {dst, src});
    end
endtask

task asm_add_R_IM;
    input [7:0] dst;
    input [7:0] src;
    begin
        asm3(8'h06, dst, src);
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

localparam JC_NEVER = 0;
localparam JC_LT = 1;
localparam JC_LE = 2;
localparam JC_ULE = 3;
localparam JC_OV = 4;
localparam JC_MI = 5;
localparam JC_Z = 6;
localparam JC_C = 7;
localparam JC_ALWAYS = 8;
localparam JC_GE = 9;
localparam JC_GT = 10;
localparam JC_UGT = 11;
localparam JC_NOV = 12;
localparam JC_PL = 13;
localparam JC_NZ = 14;
localparam JC_NC = 15;
task asm_jr;
	input [3:0] condition;
    input [7:0] addr;
    begin
        asm2({ condition, 4'hB }, addr);
    end
endtask
task asm_jp;
	input [3:0] condition;
    input [15:0] addr;
    begin
        asm3({ condition, 4'hD }, addr[15:8], addr[7:0]);
    end
endtask

task asm_dec;
    input [7:0] dst;
    begin
        asm2(8'h00, dst);
    end
endtask
task asm_rlc;
    input [7:0] dst;
    begin
        asm2(8'h10, dst);
    end
endtask
task asm_inc;
    input [7:0] dst;
    begin
        asm2(8'h20, dst);
    end
endtask
task asm_da;
    input [7:0] dst;
    begin
        asm2(8'h40, dst);
    end
endtask
task asm_com;
    input [7:0] dst;
    begin
        asm2(8'h60, dst);
    end
endtask
task asm_decw;
    input [7:0] dst;
    begin
        asm2(8'h80, dst);
    end
endtask
task asm_rl;
    input [7:0] dst;
    begin
        asm2(8'h90, dst);
    end
endtask
task asm_incw;
    input [7:0] dst;
    begin
        asm2(8'hA0, dst);
    end
endtask
task asm_clr;
    input [7:0] dst;
    begin
        asm2(8'hB0, dst);
    end
endtask
task asm_rrc;
    input [7:0] dst;
    begin
        asm2(8'hC0, dst);
    end
endtask
task asm_sra;
    input [7:0] dst;
    begin
        asm2(8'hD0, dst);
    end
endtask
task asm_rr;
    input [7:0] dst;
    begin
        asm2(8'hE0, dst);
    end
endtask
task asm_swap;
    input [7:0] dst;
    begin
        asm2(8'hF0, dst);
    end
endtask
