module Memory(
    input clk,
    input [7:0]     addr,
    output reg[7:0] dataRead,
    input           strobe
);

    reg [7:0] memory[0:255];
`include "assembly.inc"
    initial begin
        asm_ldc(0, 10); // 0C 0A
        asm_ldc(1, 20); // 1C 14
        asm_add(0, 1);  // 02 01
        asm_nop();      // FF
        asm_jump(16'h0002); // 8D 00 02
    end

    always @(posedge clk) begin
        if (strobe) begin
            dataRead <= memory[addr];
        end
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
    wire isInstrSize1 = (instruction[7:5] == 3'b111);
    wire isInstrSize3 = (instruction[7:6] == 2'b01)
                      | (instrL == 4'hD);

    reg [7:0] second;
    wire [3:0] secondH = second[7:4];
    wire [3:0] secondL = second[3:0];

    reg [7:0] third;
    wire [3:0] thirdH = third[7:4];
    wire [3:0] thirdL = third[3:0];

    reg [7:0] registers[0:15];
    reg [7:0] valueDst;
    reg [7:0] valueSrc;

    wire [7:0] valueWriteBack;
    reg [3:0] writeRegister;
    reg writeBackEn = 0;

    wire [7:0] aluIn1 = valueDst;
    wire [7:0] aluIn2 = valueSrc;
    reg [7:0] aluOut;
    assign valueWriteBack = aluOut;

    localparam ALU_LD = 0;
    localparam ALU_ADD = 1;
    reg [1:0] aluMode = 0;

    always @(*) begin
        case (aluMode)
        ALU_ADD: aluOut = aluIn1 + aluIn2;
        ALU_LD:  aluOut = aluIn1;
        default: aluOut = aluIn1;
        endcase
    end

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
            registers[writeRegister] <= valueWriteBack;
        end

        writeBackEn <= 0;

        case (state)
        STATE_FETCH_INSTR: begin
            state <= state + 1;
        end

        STATE_READ_INSTR: begin
            instruction <= memDataRead;
            pc <= pc + 1;
            state <= state + 1;
        end

        STATE_EXEC_1: begin
            if (isInstrSize1) begin
                state <= STATE_FETCH_INSTR;
            end
            else begin
                state <= state + 1;
            end
        end

        STATE_READ_2: begin
            second <= memDataRead;
            pc <= pc + 1;
            state <= state + 1;
        end

        STATE_EXEC_2: begin
            if (isInstrSize3) begin
                state <= state + 1;
            end
            else begin
                state <= STATE_FETCH_INSTR;
                case (instrL)
                4'h2: begin
                    if (instrH == 0) begin
                        writeRegister <= secondH;
                        valueDst <= registers[secondH];
                        valueSrc <= registers[secondL];
                        aluMode <= ALU_ADD;
                        writeBackEn <= 1;
                    end
                end
                4'h8: begin
                    writeRegister <= instrH;
                    valueDst <= registers[instrH];
                    valueSrc <= registers[secondL];
                    aluMode <= ALU_LD;
                    writeBackEn <= 1;
                end
                4'hC: begin
                    writeRegister <= instrH;
                    valueDst <= second;
                    aluMode <= ALU_LD;
                    writeBackEn <= 1;
                end
                endcase
            end
        end

        STATE_READ_3: begin
            third <= memDataRead;
            pc <= pc + 1;
            state <= state + 1;
        end

        STATE_EXEC_3: begin
            state <= STATE_FETCH_INSTR;
            case (instrL)
            4'hD: begin // jump
                pc <= {second, third};
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