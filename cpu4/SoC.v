module Memory(
    input clk,
    input [7:0]     addr,
    output reg[7:0] dataRead,
    input           strobe
);

    reg [7:0] memory[0:255];
`include "assembly.inc"
    localparam L0_ = 16'h2;
    initial begin
          asm_ldc(0, 10); // 0C 0A
        label(L0_);
          asm_ldc(1, 20); // 1C 14
          asm_add(0, 1);  // 02 01
          asm_nop();      // FF
          asm_jump(L0_); // 8D 00 02
    end

    always @(posedge clk) begin
        if (strobe) begin
            dataRead <= memory[addr];
        end
    end
endmodule

// see https://github.com/Time0o/z80-verilog/blob/master/source/rtl/alu.v
module Alu8(
    input [1:0] mode,
    input [7:0] a,
    input [7:0] b,
    input [7:0] flags,
    output reg [7:0] out,
    output reg [7:0] outFlags
);
    `include "alu.vh"
    `include "flags.vh"

    reg cL, cH;

    always @(*) begin
        outFlags = flags;

        case (mode)
        ALU8_ADD: begin
            { cL, out[3:0] } = { 1'b0, a[3:0] } + { 1'b0, b[3:0] };
            outFlags[FLAG_INDEX_H] = cL;
            { cH, out[7:4] } = { 1'b0, a[7:4] } + { 1'b0, b[7:4] } + { 4'b0000, cL };
            outFlags[FLAG_INDEX_C] = cH;
            outFlags[FLAG_INDEX_D] = 0;
            outFlags[FLAG_INDEX_V] = (a[7] == b[7]) & (a[7] != out[7]);
        end
        default:
            out <= a;
        endcase

        outFlags[FLAG_INDEX_Z] = (out == 0);
        outFlags[FLAG_INDEX_S] = out[7];
    end
endmodule

module Processor(
    input clk,
    output [7:0] memAddr,
    input  [7:0] memDataRead,
    output       memStrobe
);

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
    reg [1:0] aluMode = 0;
    reg [7:0] flagsIn = 0;
    reg writeFlags = 0;
    Alu8 alu8(
        .mode(aluMode),
        .a(valueDst),
        .b(valueSrc),
        .flags(flagsIn),
        .out(aluOut),
        .outFlags(flagsOut)
    );
    assign valueWriteBack = aluOut;

    localparam STATE_FETCH_INSTR  = 0;
    localparam STATE_READ_INSTR   = 1;
    localparam STATE_EXEC_1       = 2;
    localparam STATE_READ_2       = 3;
    localparam STATE_EXEC_2       = 4;
    localparam STATE_READ_3       = 5;
    localparam STATE_EXEC_3       = 6;
    reg [2:0] state = STATE_FETCH_INSTR;

    always @(posedge clk) begin
        if (writeBackEn) begin
            $display("    reg[%h] = %h", writeRegister, valueWriteBack);
            registers[writeRegister] <= valueWriteBack;
        end
        writeBackEn <= 0;

        if (writeFlags) begin
            $display("    flags = %b_%b", flagsOut[7:4], flagsOut[3:0]);
            flagsIn <= flagsOut;
        end
        writeFlags <= 0;

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
            if (isInstrSize1) begin
                state <= STATE_FETCH_INSTR;
            end
            else begin
                state <= state + 1;
            end
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
                    if (instrH == 0) begin
                        $display("    add r%h, r%h", secondH, secondL);
                        writeRegister <= secondH;
                        valueDst <= registers[secondH];
                        valueSrc <= registers[secondL];
                        aluMode <= ALU8_ADD;
                        writeBackEn <= 1;
                        writeFlags <= 1;
                    end
                end
                4'h8: begin
                    $display("    ld r%h, r%h", instrH, secondL);
                    writeRegister <= instrH;
                    valueSrc <= registers[secondL];
                    aluMode <= ALU8_LD;
                    writeBackEn <= 1;
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
                $display("    jmp %h", directAddress);
                pc <= directAddress;
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