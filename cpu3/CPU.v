module CPU(
    input clk
);

    reg [7:0] pc;
    reg [7:0] instruction, data;

    wire [3:0] instrHigh = instruction[7:4];
    wire [3:0] instrLow = instruction[3:0];
    wire [3:0] dataHigh = data[7:4];
    wire [3:0] dataLow = data[3:0];

    reg [7:0] memory[0:255];
`include "assembly.v"
    initial begin
        pc = 0;

        asm_ldc(0, 10);
        asm_ldc(1, 20);
        asm_add(0, 1);
        asm_nop();
        asm_jump(16'h0002);
    end

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

    localparam STATE_FETCH_INSTR = 0;
    localparam STATE_BYTE1       = 1;
    localparam STATE_BYTE2       = 2;
    localparam STATE_JUMP        = 3;
    reg [1:0] state = STATE_FETCH_INSTR;

    always @(posedge clk) begin
        if (writeBackEn) begin
            registers[writeRegister] <= valueWriteBack;
        end

        writeBackEn <= 0;

        case (state)
        STATE_FETCH_INSTR: begin
            instruction <= memory[pc];
            pc <= pc + 1;
            state <= STATE_BYTE1;
        end
        
        STATE_BYTE1: begin
            if ((instrLow & 4'hE) == 4'hE) begin
                state <= STATE_FETCH_INSTR;
            end
            else begin
                data <= memory[pc];
                pc <= pc + 1;
                state <= STATE_BYTE2;
            end
        end
        
        STATE_BYTE2: begin
            state <= STATE_FETCH_INSTR;
            case (instrLow)
            4'h2: begin
                if (instrHigh == 0) begin
                    writeRegister <= dataHigh;
                    valueDst <= registers[dataHigh];
                    valueSrc <= registers[dataLow];
                    aluMode <= ALU_ADD;
                    writeBackEn <= 1;
                end
            end
            4'h8: begin
                writeRegister <= instrHigh;
                valueDst <= registers[instrHigh];
                valueSrc <= registers[data[3:0]];
                aluMode <= ALU_LD;
                writeBackEn <= 1;
            end
            4'hC: begin
                writeRegister <= instrHigh;
                valueDst <= data;
                aluMode <= ALU_LD;
                writeBackEn <= 1;
            end
            4'hD: begin
                valueDst <= memory[pc];
                state <= STATE_JUMP;
            end
            endcase
        end

        STATE_JUMP: begin
            pc <= {data, valueDst};
            state <= STATE_FETCH_INSTR;
        end

        endcase
    end

endmodule