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

module JumpCondition(
    input [3:0] jumpInstrH,
    input [7:0] flags,
    output reg  out
);
    `include "flags.vh"

    reg tmp;
    always @(*) begin
        case (jumpInstrH[2:0])
        3'b000: tmp = 0;
        3'b001: tmp =  flags[FLAG_INDEX_S] ^ flags[FLAG_INDEX_V];
        3'b010: tmp = (flags[FLAG_INDEX_S] ^ flags[FLAG_INDEX_V]) | flags[FLAG_INDEX_Z];
        3'b011: tmp = flags[FLAG_INDEX_C] | flags[FLAG_INDEX_Z];
        3'b100: tmp = flags[FLAG_INDEX_V];
        3'b101: tmp = flags[FLAG_INDEX_S];
        3'b110: tmp = flags[FLAG_INDEX_Z];
        3'b111: tmp = flags[FLAG_INDEX_C];
        endcase
        out = tmp ^ jumpInstrH[3];
    end
endmodule

module Processor(
    input clk,
    output [7:0] memAddr,
    input  [7:0] memDataRead,
    output       memStrobe
);
    `include "flags.vh"

    reg [7:0] pc;
    initial begin
        pc = 0;
    end

    reg [7:0] instruction;
    wire [3:0] instrH = instruction[7:4];
    wire [3:0] instrL = instruction[3:0];
    wire isInstrSize1 = (instrL[3:1] == 3'b111);
    wire isInstrSize3 = (instrL[3:2] == 2'b01)
                      | (instrL == 4'hD);

    reg [7:0] second;
    wire [3:0] secondH = second[7:4];
    wire [3:0] secondL = second[3:0];

    reg [7:0] third;
    wire [3:0] thirdH = third[7:4];
    wire [3:0] thirdL = third[3:0];
    wire [15:0] directAddress = {second, third};

    reg [7:0] registers[0:15];
    reg [7:0] valueDst;
    reg [7:0] valueSrc;

    wire [7:0] valueWriteBack;
    reg [3:0] writeRegister;
    reg writeBackEn = 0;

    `include "alu.vh"
    wire [7:0] aluOut;
    wire [7:0] flagsOut;
    reg [3:0] aluMode = 0;
    reg [7:0] flags = 0;
    reg writeFlags = 0;
    Alu8 alu8(
        .mode(aluMode),
        .a(valueDst),
        .b(valueSrc),
        .flags(flags),
        .out(aluOut),
        .outFlags(flagsOut)
    );
    assign valueWriteBack = aluOut;

    wire jumpCondition;
    JumpCondition jc(
        .jumpInstrH(instrH),
        .flags(flags),
        .out(jumpCondition)
    );

    localparam STATE_FETCH_INSTR  = 0;
    localparam STATE_READ_INSTR   = 1;
    localparam STATE_EXEC_1       = 2;
    localparam STATE_READ_2       = 3;
    localparam STATE_EXEC_2       = 4;
    localparam STATE_READ_3       = 5;
    localparam STATE_EXEC_3       = 6;
    reg [2:0] state = STATE_FETCH_INSTR;

    always @(posedge clk) begin
        if (writeFlags) begin
            $display("    alu:    %h       %h    =>    %h", valueDst, valueSrc, aluOut);
            $display("         %b %b => %b", valueDst, valueSrc, aluOut);
            $display("    flags = %b_%b", flagsOut[7:4], flagsOut[3:0]);
            flags <= flagsOut;
        end
        writeFlags <= 0;

        if (writeBackEn) begin
            $display("    reg[%h] = %h", writeRegister, valueWriteBack);
            registers[writeRegister] <= valueWriteBack;
        end
        writeBackEn <= 0;

        case (state)
        STATE_FETCH_INSTR: begin
            $display("\n%h: read instruction", pc);
            state <= state + 1;
        end

        STATE_READ_INSTR: begin
            instruction <= memDataRead;
            pc <= pc + 1;
            state <= state + 1;
        end

        STATE_EXEC_1: begin
            $display("  %h", instruction);
            case (instrL)
            4'hE: begin
                $display("    inc r%h", instrH);
                //TODO
            end
            4'hF: begin
                state <= STATE_FETCH_INSTR;
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
                state <= state + 1;
            end
            endcase
        end

        STATE_READ_2: begin
            $display("%h: read 2nd byte", pc);
            second <= memDataRead;
            pc <= pc + 1;
            state <= state + 1;
        end

        STATE_EXEC_2: begin
            $display("  %h %h", instruction, second);
            if (isInstrSize3) begin
                state <= state + 1;
            end
            else begin
                state <= STATE_FETCH_INSTR;
                case (instrL)
                4'h2: begin
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
                        $display("    %s r%h, r%h",
                                 instrH == ALU8_ADD ? "add" :
                                 instrH == ALU8_ADC ? "adc" :
                                 instrH == ALU8_SUB ? "sub" :
                                 instrH == ALU8_SBC ? "sbc" :
                                 instrH == ALU8_OR  ? "or" :
                                 instrH == ALU8_AND ? "and" :
                                 instrH == ALU8_TCM ? "tcm" :
                                 instrH == ALU8_TM  ? "tm" :
                                 instrH == ALU8_CP  ? "cp" :
                                 instrH == ALU8_XOR ? "xor" : "?",
                                 secondH, secondL);
                        writeRegister <= secondH;
                        valueDst <= registers[secondH];
                        valueSrc <= registers[secondL];
                        aluMode <= instrH;
                        writeBackEn <= (instrH[3:2] == 2'b00)    // add, adc, sub, sbc
                                     | (instrH[3:1] == 3'b010)   // or, and
                                     | (instrH      == 4'b1011); // xor
                        writeFlags <= 1;
                    end
                    default: begin
                        $display("    ?", instruction);
                    end
                    endcase
                end
                4'h8: begin
                    $display("    ld r%h, %h", instrH, secondL);
                    writeRegister <= instrH;
                    valueSrc <= registers[secondL];
                    aluMode <= ALU8_LD;
                    writeBackEn <= 1;
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
                    $display("    jr %h, %h", instrH, secondL);
                    //TODO
                end
                4'hC: begin
                    $display("    ld r%h, #%h", instrH, second);
                    writeRegister <= instrH;
                    valueDst <= second;
                    aluMode <= ALU8_LD;
                    writeBackEn <= 1;
                end
                endcase
            end
        end

        STATE_READ_3: begin
            $display("%h: read 3rd byte", pc);
            third <= memDataRead;
            pc <= pc + 1;
            state <= state + 1;
        end

        STATE_EXEC_3: begin
            $display("  %h %h %h", instruction, second, third);
            state <= STATE_FETCH_INSTR;
            case (instrL)
            4'hD: begin // jump
                $display("    jmp %h, %h", instrH, directAddress);
                if (jumpCondition) begin
                    pc <= directAddress;
                end
            end
            default: begin
            end
            endcase
        end

        endcase
    end

    assign memAddr = pc;
    assign memStrobe = (state == STATE_FETCH_INSTR)
                     | (state == STATE_EXEC_1 & ~isInstrSize1)
                     | (state == STATE_EXEC_2 & isInstrSize3);
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
