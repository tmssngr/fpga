`default_nettype none

module Memory(
    input clk,
    input    [15:0] addr,
    input     [7:0] dataWrite,
    output reg[7:0] dataRead,
    input           write,
    input           strobe
);

    reg [7:0] memory[0:8191];
`include "assembly.vh"
`include "program.vh"

    always @(posedge clk) begin
        if (strobe) begin
            if (write) begin
                memory[addr] <= dataWrite;
                dataRead <= dataWrite;
            end
            else begin
                dataRead <= memory[addr];
            end
        end
    end
endmodule

`include "Alu.v"

module Processor(
    input         clk,
    input         reset,
    output [15:0] memAddr,
    input  [7:0]  memDataRead,
    output [7:0]  memDataWrite,
    output        memWrite,
    output        memStrobe
);
    `include "flags.vh"

    reg [15:0] pc, sp, addr;
    initial begin
        pc = 'hC;
        sp = 0;
    end

    reg  [7:0] instruction;
    wire [3:0] instrH = instruction[7:4];
    wire [3:0] instrL = instruction[3:0];
    wire isJumpRel = instrL == 4'hB;
    wire isJumpDA = instrL == 4'hD;
    wire isInstrSize1 = (instrL[3:1] == 3'b111);
    wire isInstrSize3 = (instrL[3:2] == 2'b01)
                      | isJumpDA;
    wire isInstrSize2 = ~isInstrSize1 & ~isInstrSize3;

    reg  [7:0] second;
    wire [3:0] secondH = second[7:4];
    wire [3:0] secondL = second[3:0];

    reg  [7:0] third;
    wire [3:0] thirdH = third[7:4];
    wire [3:0] thirdL = third[3:0];
    wire [15:0] directAddress = {second, third};

    reg [3:0] rp = 0;
    reg [7:0] registers[0:'h7F];
    reg [7:0] p01m = 8'b01_0_01_1_01;
    //                  || | || | ++ P00-P03 Mode: 00 output, 01 input, 1x address A8-A11
    //                  || | || +--- Stack: 0 external,  1 internal
    //                  || | ++----- P1 Mode: 00 Output, 01 Input, 10 AD0-AD7, 11 tristate
    //                  || +-------- Memory timing: 0 normal, 1 extended
    //                  ++---------- P04-P07 Mode: 00 output, 01 input, 1x A12-A15 
    wire stackInternal = p01m[2];

    reg [7:0] srcRegister;
    reg [7:0] dstRegister;
    reg writeRegister = 0;

    `include "alu.vh"
    reg  [7:0] aluA = 0;
    reg  [7:0] aluB = 0;
    reg  [4:0] aluMode;
    wire [7:0] aluOut;
    reg  [7:0] flags = 0;
    wire [7:0] flagsOut;
    reg writeFlags = 0;
    Alu alu(
        .mode(aluMode),
        .a(aluA),
        .b(aluB),
        .flags(flags),
        .out(aluOut),
        .outFlags(flagsOut)
    );

    function [7:0] r4(
        input [3:0] r
    );
        r4 = { rp, r };
    endfunction

    function [7:0] r8(
        input [7:0] r
    );
        if (r[7:4] == 4'hE)
            r8 = r4(r[3:0]);
        else
            r8 = r;
    endfunction

    function [7:0] readRegister8(
        input [7:0] r
    );
        casez (r)
        8'b0???_????: readRegister8 = registers[r[6:0]];
        8'hF8:        readRegister8 = p01m;
        8'hFC:        readRegister8 = flags;
        8'hFD:        readRegister8 = { rp, 4'h0 };
        8'hFE:        readRegister8 = sp[15:8];
        8'hFF:        readRegister8 = sp[7:0];
        default:      readRegister8 = 0;
        endcase
    endfunction

    function [7:0] readRegister4(
        input [3:0] r
    );
        readRegister4 = readRegister8(r4(r));
    endfunction

    function [1:4*8] alu1OpName( // maximum of 4 characters
        input [3:0] instrH
    );
    begin
        case (instrH)
        ALU1_DEC : alu1OpName = "dec";
        ALU1_RLC : alu1OpName = "rlc";
        ALU1_INC : alu1OpName = "inc";
        ALU1_DA  : alu1OpName = "da";
        ALU1_COM : alu1OpName = "com";
        ALU1_DECW: alu1OpName = "decw";
        ALU1_RL  : alu1OpName = "rl";
        ALU1_INCW: alu1OpName = "incw";
        ALU1_CLR : alu1OpName = "clr";
        ALU1_RRC : alu1OpName = "rrc";
        ALU1_SRA : alu1OpName = "sra";
        ALU1_RR  : alu1OpName = "rr";
        ALU1_SWAP: alu1OpName = "swap";
        default  : alu1OpName = "?";
        endcase;
    end
    endfunction

    function [4:0] alu1OpCode(
        input[3:0] instrH
    );
        alu1OpCode = { 1'b0, instrH };
    endfunction

    function [4:0] alu2OpCode(
        input[3:0] instrH
    );
        alu2OpCode = { 1'b1, instrH };
    endfunction

    function [1:3*8] alu2OpName( // maximum of 3 characters
        input [3:0] instrH
    );
    begin
        case (alu2OpCode(instrH))
        ALU2_ADD: alu2OpName = "add";
        ALU2_ADC: alu2OpName = "adc";
        ALU2_SUB: alu2OpName = "sub";
        ALU2_SBC: alu2OpName = "sbc";
        ALU2_OR : alu2OpName = "or";
        ALU2_AND: alu2OpName = "and";
        ALU2_TCM: alu2OpName = "tcm";
        ALU2_TM : alu2OpName = "tm";
        ALU2_CP : alu2OpName = "cp";
        ALU2_XOR: alu2OpName = "xor";
        default : alu2OpName = "?";
        endcase
    end
    endfunction

    reg takeBranchTmp;
    always @(*) begin
        case (instrH[2:0])
        0: takeBranchTmp = 0;
        1: takeBranchTmp =  flags[FLAG_INDEX_S] ^ flags[FLAG_INDEX_V];
        2: takeBranchTmp = (flags[FLAG_INDEX_S] ^ flags[FLAG_INDEX_V]) | flags[FLAG_INDEX_Z];
        3: takeBranchTmp =  flags[FLAG_INDEX_C] | flags[FLAG_INDEX_Z];
        4: takeBranchTmp =  flags[FLAG_INDEX_V];
        5: takeBranchTmp =  flags[FLAG_INDEX_S];
        6: takeBranchTmp =  flags[FLAG_INDEX_Z];
        7: takeBranchTmp =  flags[FLAG_INDEX_C];
        endcase
    end
    wire takeBranch = takeBranchTmp ^ instrH[3];

    function [1:3*8] ccName( // maximum of 3 characters
        input [3:0] instrH
    );
    begin
        case (instrH)
        0: ccName = "f";
        1: ccName = "lt";
        2: ccName = "le";
        3: ccName = "ule";
        4: ccName = "ov";
        5: ccName = "mi";
        6: ccName = "z";
        7: ccName = "c";
        8: ccName = "";
        9: ccName = "ge";
        10: ccName = "gt";
        11: ccName = "ugt";
        12: ccName = "nov";
        13: ccName = "pl";
        14: ccName = "nz";
        15: ccName = "nc";
        endcase
    end
    endfunction

    `include "states.vh"
    reg [STATES_MAX_BIT:0] state = STATE_FETCH_INSTR;

    wire [15:0] nextRelativePc = pc + { {8{second[7]}}, second };
    wire [15:0] nextPc = (  state == STATE_READ_INSTR
                         | state == STATE_READ_2
                         | state == STATE_READ_3)
                         ? pc + 1
                         : ( state == STATE_DECODE & isJumpDA & takeBranch) 
                            ? directAddress
                            : ( (state == STATE_DECODE & isJumpRel & takeBranch)
                              || (state == STATE_DJNZ2 && flagsOut[FLAG_INDEX_Z] == 1'b0 )
                              ) 
                                ? nextRelativePc
                                : pc;
    assign memAddr = (state == STATE_READ_MEM1)
                   | (state == STATE_WRITE_MEM)
                     ? addr : pc;
    assign memDataWrite = aluA;
    assign memWrite = (state == STATE_WRITE_MEM);
    assign memStrobe = (state == STATE_FETCH_INSTR)
                     | (state == STATE_WAIT_2 & ~isInstrSize1)
                     | (state == STATE_WAIT_3)
                     | (state == STATE_READ_MEM1)
                     | (state == STATE_WRITE_MEM);

    always @(posedge clk) begin
        if (writeFlags) begin
            $display("    alu:    %h       %h    =>    %h", aluA, aluB, aluOut);
            $display("         %b %b => %b", aluA, aluB, aluOut);
            $display("    flags = %b_%b", flagsOut[7:4], flagsOut[3:0]);
            flags <= flagsOut;
        end
        writeFlags <= 0;

        if (writeRegister) begin
            $display("    reg[%h] = %h", dstRegister, aluOut);
            casez (dstRegister)
            8'b0???_????: registers[dstRegister] <= aluOut;
            8'hF8:        p01m                   <= aluOut;
            8'hFC:        flags                  <= aluOut;
            8'hFD:        rp                     <= aluOut[7:4];
            8'hFE:        sp[15:8]               <= aluOut;
            8'hFF:        sp[7:0]                <= aluOut;
            endcase
        end
        writeRegister <= 0;

        state <= state + 1;

        case (state)
        STATE_FETCH_INSTR: begin
            $display("\n%h: read instruction", pc);
        end

        STATE_READ_INSTR: begin
            instruction <= memDataRead;
        end

        STATE_WAIT_2: begin
            $display("  %h", instruction);
            if (isInstrSize1) begin
                state <= STATE_DECODE;
            end
        end

        STATE_READ_2: begin
            $display("%h: read 2nd byte", pc);
            second <= memDataRead;
            if (isInstrSize2) begin
                state <= STATE_DECODE;
            end
        end

        STATE_WAIT_3: begin
            $display("  %h %h", instruction, second);
        end

        STATE_READ_3: begin
            $display("%h: read 3rd byte", pc);
            third <= memDataRead;
        end

        STATE_DECODE: begin
            if (isInstrSize2) begin
                $display("  %h %h", instruction, second);
            end else if (isInstrSize3) begin
                $display("  %h %h %h", instruction, second, third);
            end

            state <= STATE_FETCH_INSTR;

            case (instrL)
            4'h0: begin
                case (instrH)
                4'h3: begin
                    $display("    jp IRR%h", second);
                    //TODO
                end
                4'h5: begin
                    $display("    pop %h", second);
                    // dst <- @SP
                    // SP <- SP + 1
                    srcRegister <= r8(second);
                    state <= STATE_POP;
                end
                4'h7: begin
                    $display("    push %h", second);
                    sp <= sp - 1;
                    srcRegister <= r8(second);
                    state <= STATE_PUSH;
                end
                4'h8: begin
                    $display("    decw %h", second);
                    aluMode <= ALU1_DEC;
                    writeRegister <= 1;
                    writeFlags <= 1;
                    dstRegister <= r8(second | 8'h1);
                    aluA <= readRegister8(second | 8'h1);
                    state <= STATE_ALU1_WORD;
                end
                4'hA: begin
                    $display("    incw %h", second);
                    aluMode <= ALU1_INC;
                    writeRegister <= 1;
                    writeFlags <= 1;
                    dstRegister <= r8(second | 8'h1);
                    aluA <= readRegister8(second | 8'h1);
                    state <= STATE_ALU1_WORD;
                end
                default: begin
                    $display("   %s %h", 
                             alu1OpName(instrH), second);
                    aluMode <= alu1OpCode(instrH);
                    srcRegister <= r8(second);
                    state <= STATE_ALU1_OP;
                end
                endcase
            end
            4'h1: begin
                case (instrH)
                4'h3: begin
                    $display("    srp %h", second);
                    rp <= second[7:4];
                end
                4'h5: begin
                    $display("    pop @%h", second);
                    //TODO
                end
                4'h7: begin
                    $display("    push @%h", second);
                    //TODO
                end
                4'h8: begin
                    $display("    decw @%h", second);
                    //TODO
                end
                4'hA: begin
                    $display("    incw @%h", second);
                    //TODO
                end
                default: begin
                    $display("   %s @%h", 
                             alu1OpName(instrH), second);
                    aluMode <= alu1OpCode(instrH);
                    srcRegister <= readRegister8(r8(second));
                    state <= STATE_ALU1_OP;
                end
                endcase
            end
            4'h2: begin
                casez (instrH)
                4'h8: begin
                    $display("    lde r%h, Irr%h",
                             secondH, secondL);
                    //TODO
                end
                4'h9: begin
                    $display("    lde Irr%h, r%h",
                             secondL, secondH);
                    //TODO
                end
                4'hC: begin
                    $display("    ldc r%h, Irr%h",
                             secondH, secondL);
                    dstRegister <= r4(secondH);
                    addr[15:8] <= readRegister4(secondL & ~1);
                    srcRegister <= r4(secondL | 1);
                    state <= STATE_LDC_READ;
                end
                4'hD: begin
                    $display("    ldc Irr%h, r%h",
                             secondL, secondH);
                    addr[15:8] <= readRegister4(secondL & ~1);
                    dstRegister <= r4(secondL | 1);
                    srcRegister <= r4(secondH);
                    state <= STATE_LDC_WRITE1;
                end
                4'b111x: begin
                    $display("    ? %h", second);
                end
                default: begin
                    $display("    %s r%h, r%h",
                             alu2OpName(instrH),
                             secondH, secondL);
                    dstRegister <= r4(secondH);
                    aluA <= readRegister4(secondH);
                    //TODO
                    aluB <= readRegister4(secondL);
                    state <= STATE_ALU2_OP;
                end
                endcase
            end
            4'h3: begin
                casez (instrH)
                4'h8: begin
                    $display("    ldei r%h, Irr%h",
                             secondH, secondL);
                    //TODO
                end
                4'h9: begin
                    $display("    ldei Irr%h, r%h",
                             secondL, secondH);
                    //TODO
                end
                4'hC: begin
                    $display("    ldci r%h, Irr%h",
                             secondH, secondL);
                    //TODO
                end
                4'hD: begin
                    $display("    ldci Irr%h, r%h",
                             secondL, secondH);
                    //TODO
                end
                4'hE: begin
                    $display("    ld r%h, Ir%h",
                             secondL, secondH);
                    //TODO
                end
                4'hF: begin
                    $display("    ld Ir%h, r%h",
                             secondL, secondH);
                    //TODO
                end
                default: begin
                    $display("    %s r%h, Ir%h",
                             alu2OpName(instrH),
                             secondH, secondL);
                    dstRegister <= r4(secondH);
                    aluA <= readRegister4(secondH);
                    srcRegister <= readRegister4(secondL);
                    state <= STATE_ALU2_IR;
                end
                endcase
            end
            4'h4: begin
                case (instrH)
                4'b100x,
                4'b1100,
                4'b1111: begin
                    $display("    ? %h", instruction);
                end
                4'hD: begin
                    $display("    call IRR%h", directAddress);
                    //TODO
                end
                4'hE: begin
                    $display("    ld %h, %h", third, second);
                    dstRegister <= r8(third);
                    aluA <= readRegister8(r8(second));
                    aluMode <= ALU1_LD;
                    writeRegister <= 1;
                end
                default: begin
                    $display("    %s %h, %h",
                             alu2OpName(instrH),
                             third, second);
                    dstRegister <= r8(third);
                    aluA <= readRegister8(r8(third));
                    //TODO
                    aluB <= readRegister8(r8(second));
                    state <= STATE_ALU2_OP;
                end
                endcase
            end
            4'h6: begin
                case (instrH)
                4'b100x,
                4'b1100,
                4'b1111: begin
                    $display("    ? %h", instruction);
                end
                4'hD: begin
                    $display("    call %h", directAddress);
                    //TODO
                end
                4'hE: begin
                    $display("    ld %h, #%h", second, third);
                    dstRegister <= r8(second);
                    aluA <= third;
                    aluMode <= ALU1_LD;
                    writeRegister <= 1;
                end
                default: begin
                    $display("    %s %h, #%h",
                             alu2OpName(instrH),
                             second, third);
                    dstRegister <= r8(second);
                    aluA <= readRegister8(r8(second));
                    aluB <= third;
                    state <= STATE_ALU2_OP;
                end
                endcase
            end
            4'h8: begin
                $display("    ld r%h, %h", instrH, secondL);
                dstRegister <= r4(instrH);
                aluB <= readRegister8(r8(second));
                aluMode <= ALU1_LD;
                writeRegister <= 1;
            end
            4'h9: begin
                $display("    ld %h, r%h", secondL, instrH);
                //TODO
            end
            4'hA: begin
                $display("    djnz r%h, %h", instrH, second);
                dstRegister <= r4(instrH);
                state <= STATE_DJNZ1;
            end
            4'hB: begin
                $display("    jr %s, %h", ccName(instrH), second);
            end
            4'hC: begin
                $display("    ld r%h, #%h", instrH, second);
                dstRegister <= r4(instrH);
                aluA <= second;
                aluMode <= ALU1_LD;
                writeRegister <= 1;
            end
            4'hD: begin
                $display("    jmp %s, %h", ccName(instrH), directAddress);
            end
            4'hE: begin
                $display("    inc r%h", instrH);
                //TODO
            end
            4'hF: begin
                casez (instrH)
                4'h8: begin
                    $display("    di");
                    //TODO
                end
                4'h9: begin
                    $display("    ei");
                    //TODO
                end
                4'hA: begin
                    $display("    ret");
                    //TODO
                end
                4'hB: begin
                    $display("    iret");
                    //TODO
                end
                4'b110?: begin
                    $display("    %scf", instrH[0] ? "s" : "r");
                    flags[FLAG_INDEX_C] <= instrH[0];
                end
                4'hE: begin
                    $display("    ccf");
                    flags[FLAG_INDEX_C] <= ~flags[FLAG_INDEX_C];
                end
                4'hF: begin
                    $display("    nop");
                end
                default: begin
                    $display("    ?");
                end
                endcase
            end
            default: begin
            end
            endcase
        end

        STATE_ALU1_WORD: begin
            dstRegister <= { dstRegister[7:1], 1'b0 };
            aluA <= readRegister8({dstRegister[7:1], 1'b0});
            // inc(w) -> instrH[1] == 1
            // dec(w) -> instrH[1] == 0
            // carry? (aluOut == 0x00 for inc, == 0xFF for dec)
            if (aluOut == {8{~instrH[1]}}) begin
                aluMode <= aluMode | 'h8; // inc/dec -> incw/decw
                // ALU1_INCW and ALU1_DECW have a special handling for the zero flag
            end
            else begin
                aluMode <= ALU1_INCW_UPPER_0;
            end
            writeRegister <= 1;
            writeFlags <= 1;
            state <= STATE_FETCH_INSTR;
        end

        STATE_ALU1_OP: begin
            aluA <= readRegister8(srcRegister);
            dstRegister <= srcRegister;
            writeRegister <= 1;
            writeFlags <= 1;

            if (aluMode == ALU1_DA) begin
                state <= STATE_ALU1_DA;
            end
            else begin
                state <= STATE_FETCH_INSTR;
            end
        end

        STATE_ALU1_DA: begin
            aluA <= aluOut;
            aluMode <= ALU1_DA_H;
            writeRegister <= 1;
            writeFlags <= 1;
            dstRegister <= srcRegister;
            state <= STATE_FETCH_INSTR;
        end

        STATE_ALU2_IR: begin
            aluB <= readRegister8(srcRegister);
        end

        STATE_ALU2_OP: begin
            aluMode <= alu2OpCode(instrH);
            writeRegister <= (instrH[3:2] == 2'b00)     // add, adc, sub, sbc
                            | (instrH[3:1] == 3'b010)   // or, and
                            | (instrH      == 4'b1011); // xor
            writeFlags <= 1;
            state <= STATE_FETCH_INSTR;
        end

        STATE_PUSH: begin
            aluMode <= ALU1_LD;
            aluA <= readRegister8(srcRegister);
            dstRegister <= sp[7:0];
            writeRegister <= 1;
            state <= STATE_FETCH_INSTR;
        end

        STATE_POP: begin
            aluMode <= ALU1_LD;
            aluA <= readRegister8(sp[7:0]);
            sp <= sp + 1;
            dstRegister <= srcRegister;
            writeRegister <= 1;
            state <= STATE_FETCH_INSTR;
        end

        STATE_DJNZ1: begin
            aluA <= readRegister8(dstRegister);
            aluMode <= ALU1_DEC;
            writeRegister <= 1;
        end

        STATE_DJNZ2: begin
            // needs a special state to handle the pc
            state <= STATE_FETCH_INSTR;
        end

        STATE_LDC_READ: begin
            addr[7:0] <= readRegister8(srcRegister);
            state <= STATE_READ_MEM1;
        end

        STATE_LDC_WRITE1: begin
            addr[7:0] <= readRegister8(dstRegister);
        end
        STATE_LDC_WRITE2: begin
            aluA <= readRegister8(srcRegister);
            state <= STATE_WRITE_MEM;
        end

        STATE_READ_MEM1: begin
        end
        STATE_READ_MEM2: begin
            aluA <= memDataRead;
            aluMode <= ALU1_LD;
            writeRegister <= 1;
            state <= STATE_FETCH_INSTR;
        end

        STATE_WRITE_MEM: begin
            state <= STATE_FETCH_INSTR;
        end

        endcase

        pc <= nextPc;
    end
endmodule

module SoC(
    input clk
);
    wire [15:0] memAddr;
    wire [7:0]  memDataRead;
    wire [7:0]  memDataWrite;
    wire        memWrite;
    wire        memStrobe;

    Memory mem(
        .clk(clk),
        .addr(memAddr),
        .dataRead(memDataRead),
        .dataWrite(memDataWrite),
        .write(memWrite),
        .strobe(memStrobe)
    );

    Processor proc(
        .clk(clk),
        .memAddr(memAddr),
        .memDataRead(memDataRead),
        .memDataWrite(memDataWrite),
        .memWrite(memWrite),
        .memStrobe(memStrobe)
    );
endmodule
