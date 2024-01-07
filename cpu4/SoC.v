`default_nettype none

module Memory(
    input clk,
    input [7:0]     addr,
    output reg[7:0] dataRead,
    input           strobe
);

    reg [7:0] memory[0:255];
`include "assembly.inc"
`include "program.inc"

    always @(posedge clk) begin
        if (strobe) begin
            dataRead <= memory[addr];
        end
    end
endmodule

// see https://github.com/Time0o/z80-verilog/blob/master/source/rtl/alu.v
module Alu8(
    input [3:0] mode,
    input [7:0] a,
    input [7:0] b,
    input [7:0] flags,
    output reg [7:0] out,
    output reg [7:0] outFlags
);
    `include "alu.vh"
    `include "flags.vh"

    reg cL, cH;
    reg [7:0] a_and;

    always @(*) begin
        outFlags = flags;

        case (mode)
        ALU8_ADD,
        ALU8_ADC: begin
            { cL, out[3:0] } = { 1'b0, a[3:0] } + { 1'b0, b[3:0] } + { 8'b0, flags[FLAG_INDEX_C] & mode[0] };
            outFlags[FLAG_INDEX_H] = cL;
            { cH, out[7:4] } = { 1'b0, a[7:4] } + { 1'b0, b[7:4] } + { 4'b0000, cL };
            outFlags[FLAG_INDEX_C] = cH;
            outFlags[FLAG_INDEX_D] = 0;
            outFlags[FLAG_INDEX_V] = (a[7] == b[7]) & (a[7] != out[7]);
        end
        ALU8_SUB,
        ALU8_SBC,
        ALU8_CP: begin
            { cL, out[3:0] } = { 1'b0, a[3:0] } - { 1'b0, b[3:0] } - { 8'b0, flags[FLAG_INDEX_C] & mode[0] };
            outFlags[FLAG_INDEX_H] = cL;
            { cH, out[7:4] } = { 1'b0, a[7:4] } - { 1'b0, b[7:4] } - { 4'b0000, cL };
            outFlags[FLAG_INDEX_C] = cH;
            outFlags[FLAG_INDEX_D] = 1;
            outFlags[FLAG_INDEX_V] = (a[7] == b[7]) & (a[7] != out[7]);
        end
        ALU8_OR: begin
            out = a | b;
            outFlags[FLAG_INDEX_V] = 0;
        end
        ALU8_AND,
        ALU8_TCM,
        ALU8_TM: begin
            a_and = mode[0] ? a : ~a;
            out = a_and & b;
            outFlags[FLAG_INDEX_V] = 0;
        end
        ALU8_XOR: begin
            out = a ^ b;
            outFlags[FLAG_INDEX_V] = 0;
        end
        default:
            out <= a;
        endcase

        outFlags[FLAG_INDEX_Z] = (out == 0);
        outFlags[FLAG_INDEX_S] = out[7];
    end
endmodule

module Processor(
    input        clk,
    output [7:0] memAddr,
    input  [7:0] memDataRead,
    output       memStrobe
);
    `include "flags.vh"

    reg [7:0] pc;
    initial begin
        pc = 0;
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

    reg [3:0] dstRegister;
    reg writeRegister = 0;

    `include "alu.vh"
    reg  [7:0] aluA;
    reg  [7:0] aluB;
    reg  [3:0] aluMode;
    wire [7:0] aluOut;
    reg  [7:0] flags = 0;
    wire [7:0] flagsOut;
    reg writeFlags = 0;
    Alu8 alu8(
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
        8'hFC:        readRegister8 = flags;
        8'hFD:        readRegister8 = { rp, 4'h0 };
        default:      readRegister8 = 0;
        endcase
    endfunction

    function [7:0] readRegister4(
        input [3:0] r
    );
        readRegister4 = readRegister8(r4(r));
    endfunction

    function [1:3*8] alu8OpName( // maximum of 3 characters
        input [3:0] instrH
    );
    begin
        alu8OpName = instrH == ALU8_ADD ? "add" :
                     instrH == ALU8_ADC ? "adc" :
                     instrH == ALU8_SUB ? "sub" :
                     instrH == ALU8_SBC ? "sbc" :
                     instrH == ALU8_OR  ? "or"  :
                     instrH == ALU8_AND ? "and" :
                     instrH == ALU8_TCM ? "tcm" :
                     instrH == ALU8_TM  ? "tm"  :
                     instrH == ALU8_CP  ? "cp"  :
                     instrH == ALU8_XOR ? "xor" :
                     "?";
    end
    endfunction

    reg regBranchTmp;
    always @(*) begin
        case (instrH[2:0])
        0: regBranchTmp = 0;
        1: regBranchTmp =  flags[FLAG_INDEX_S] ^ flags[FLAG_INDEX_V];
        2: regBranchTmp = (flags[FLAG_INDEX_S] ^ flags[FLAG_INDEX_V]) | flags[FLAG_INDEX_Z];
        3: regBranchTmp =  flags[FLAG_INDEX_C] | flags[FLAG_INDEX_Z];
        4: regBranchTmp =  flags[FLAG_INDEX_V];
        5: regBranchTmp =  flags[FLAG_INDEX_S];
        6: regBranchTmp =  flags[FLAG_INDEX_Z];
        7: regBranchTmp =  flags[FLAG_INDEX_C];
        endcase
    end
    wire takeBranch = regBranchTmp ^ instrH[3];

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

    localparam STATE_FETCH_INSTR  = 0;
    localparam STATE_READ_INSTR   = 1;
    localparam STATE_WAIT_2       = 2;
    localparam STATE_READ_2       = 3;
    localparam STATE_WAIT_3       = 4;
    localparam STATE_READ_3       = 5;
    localparam STATE_EXEC         = 6;
    reg [2:0] state = STATE_FETCH_INSTR;
    wire [2:0] nextState = (  (isInstrSize1 && state == STATE_WAIT_2)
                           || (isInstrSize2 && state == STATE_READ_2)
                           )
                           ? STATE_EXEC
                           : (state == STATE_EXEC)
                                ? STATE_FETCH_INSTR
                                : state + 1;

    wire [7:0] nextPc = (  state == STATE_READ_INSTR
                         | state == STATE_READ_2
                         | state == STATE_READ_3)
                         ? pc + 1
                         : ( state == STATE_EXEC & isJumpDA & takeBranch) 
                            ? directAddress
                            : ( state == STATE_EXEC & isJumpRel & takeBranch) 
                                ? pc + { {8{second[7]}}, second }
                                : pc;
    assign memStrobe = (state == STATE_FETCH_INSTR)
                     | (state == STATE_WAIT_2 & ~isInstrSize1)
                     | (state == STATE_WAIT_3);

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
            8'hFC:        flags                  <= aluOut;
            8'hFD:        rp                     <= aluOut[7:4];
            endcase
        end
        writeRegister <= 0;

        case (state)
        STATE_FETCH_INSTR: begin
            $display("\n%h: read instruction", pc);
        end

        STATE_READ_INSTR: begin
            instruction <= memDataRead;
        end

        STATE_WAIT_2: begin
            $display("  %h", instruction);
        end

        STATE_READ_2: begin
            $display("%h: read 2nd byte", pc);
            second <= memDataRead;
        end

        STATE_WAIT_3: begin
            $display("  %h %h", instruction, second);
        end

        STATE_READ_3: begin
            $display("%h: read 3rd byte", pc);
            third <= memDataRead;
        end

        STATE_EXEC: begin
            if (isInstrSize2) begin
                $display("  %h %h", instruction, second);
            end else if (isInstrSize3) begin
                $display("  %h %h %h", instruction, second, third);
            end
            case (instrL)
            4'h1: begin
                $display("    srp %h", second);
                rp <= second[7:4];
            end
            4'h2,
            4'h6: begin
                case (instrH)
                ALU8_ADD,
                ALU8_ADC,
                ALU8_SUB,
                ALU8_SBC,
                ALU8_OR,
                ALU8_AND,
                ALU8_TCM,
                ALU8_TM,
                ALU8_CP,
                ALU8_XOR: begin
                    aluMode <= instrH;
                    writeRegister <= (instrH[3:2] == 2'b00)     // add, adc, sub, sbc
                                    | (instrH[3:1] == 3'b010)   // or, and
                                    | (instrH      == 4'b1011); // xor
                    writeFlags <= 1;
                    case (instrL)
                    4'h2: begin
                        $display("    %s r%h, r%h",
                                    alu8OpName(instrH),
                                    secondH, secondL);
                        dstRegister <= r4(secondH);
                        aluA <= readRegister4(secondH);
                        aluB <= readRegister4(secondL);
                    end
                    4'h6: begin
                        $display("    %s %h, #%h",
                                alu8OpName(instrH),
                                second, third);
                        dstRegister <= r8(second);
                        aluA <= readRegister8(r8(second));
                        aluB <= third;
                    end
                    endcase
                end
                default: begin
                    $display("    ?", instruction);
                end
                endcase
            end
            4'h8: begin
                $display("    ld r%h, %h", instrH, secondL);
                dstRegister <= r4(instrH);
                aluB <= readRegister8(r8(second));
                aluMode <= ALU8_LD;
                writeRegister <= 1;
            end
            4'h9: begin
                $display("    ld %h, r%h", secondL, instrH);
                //TODO
            end
            4'hA: begin
                $display("    djnz r%h, %h", instrH, secondL);
                //TODO
            end
            4'hB: begin
                $display("    jr %s, %h", ccName(instrH), second);
            end
            4'hC: begin
                $display("    ld r%h, #%h", instrH, second);
                dstRegister <= r4(instrH);
                aluA <= second;
                aluMode <= ALU8_LD;
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

        endcase

        state <= nextState;
        pc <= nextPc;
    end

    assign memAddr = pc;
endmodule

module SoC(
    input clk
);

    wire [7:0] memAddr;
    wire [7:0] memData;
    wire       memStrobe;

    Memory mem(
        .clk(clk),
        .addr(memAddr),
        .dataRead(memData),
        .strobe(memStrobe)
    );

    Processor proc(
        .clk(clk),
        .memAddr(memAddr),
        .memDataRead(memData),
        .memStrobe(memStrobe)
    );
endmodule
