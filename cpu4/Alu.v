`ifndef ALU_V
`define ALU_V

// see https://github.com/Time0o/z80-verilog/blob/master/source/rtl/alu.v
module Alu(
    input [4:0] mode,
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

        casez (mode)
        5'b0_?000: begin // ALU1_DEC, ALU1_DECW
            out = a - 8'b01;
            outFlags[FLAG_INDEX_V] = a[7] & ~out[7];
        end
        ALU1_RLC: begin
            out = { a[6:0], flags[FLAG_INDEX_C] };
            outFlags[FLAG_INDEX_C] = a[7];
        end
        5'b0_?010: begin // ALU1_INC, ALU1_INCW
            out = a + 8'b01;
            outFlags[FLAG_INDEX_V] = ~a[7] & out[7];
        end
        ALU1_INCW_UPPER_0: begin
            out = a;
            outFlags[FLAG_INDEX_V] = 0;
        end
        ALU1_DA: begin
            //TODO
        end
        ALU1_COM: begin
            out = ~a;
            outFlags[FLAG_INDEX_V] = 0;
        end
        ALU1_RL: begin
            out = { a[6:0], a[7] };
            outFlags[FLAG_INDEX_C] = a[7];
        end
        ALU1_RRC: begin
            out = { flags[FLAG_INDEX_C], a[7:1] };
            outFlags[FLAG_INDEX_C] = a[0];
        end
        ALU1_SRA: begin
            out = { a[7], a[7:1] };
            outFlags[FLAG_INDEX_C] = a[0];
        end
        ALU1_RR: begin
            out = { a[0], a[7:1] };
            outFlags[FLAG_INDEX_C] = a[0];
        end
        ALU1_SWAP: begin
            out = { a[3:0], a[7:4] };
        end
        ALU2_ADD,
        ALU2_ADC: begin
            { cL, out[3:0] } = { 1'b0, a[3:0] } + { 1'b0, b[3:0] } + { 8'b0, flags[FLAG_INDEX_C] & mode[0] };
            outFlags[FLAG_INDEX_H] = cL;
            { cH, out[7:4] } = { 1'b0, a[7:4] } + { 1'b0, b[7:4] } + { 4'b0000, cL };
            outFlags[FLAG_INDEX_C] = cH;
            outFlags[FLAG_INDEX_D] = 0;
            outFlags[FLAG_INDEX_V] = (a[7] == b[7]) & (a[7] != out[7]);
        end
        ALU2_SUB,
        ALU2_SBC,
        ALU2_CP: begin
            { cL, out[3:0] } = { 1'b0, a[3:0] } - { 1'b0, b[3:0] } - { 8'b0, flags[FLAG_INDEX_C] & mode[0] };
            outFlags[FLAG_INDEX_H] = cL;
            { cH, out[7:4] } = { 1'b0, a[7:4] } - { 1'b0, b[7:4] } - { 4'b0000, cL };
            outFlags[FLAG_INDEX_C] = cH;
            outFlags[FLAG_INDEX_D] = 1;
            outFlags[FLAG_INDEX_V] = (a[7] == b[7]) & (a[7] != out[7]);
        end
        ALU2_OR: begin
            out = a | b;
            outFlags[FLAG_INDEX_V] = 0;
        end
        ALU2_AND,
        ALU2_TCM,
        ALU2_TM: begin
            a_and = mode[0] ? a : ~a;
            out = a_and & b;
            outFlags[FLAG_INDEX_V] = 0;
        end
        ALU2_XOR: begin
            out = a ^ b;
            outFlags[FLAG_INDEX_V] = 0;
        end
        ALU1_LD: begin
            out <= a;
        end
        // ALU1_CLR
        default : begin
            out = 0;
        end
        endcase

        case (mode)
        ALU1_CLR,  // keep it
        ALU1_LD  : outFlags[FLAG_INDEX_Z] = flags[FLAG_INDEX_Z];

        ALU1_DECW, // set only if set from the lower-byte operation, too
        ALU1_INCW,
        ALU1_INCW_UPPER_0: outFlags[FLAG_INDEX_Z] = flags[FLAG_INDEX_Z] & (out == 0);

        default  : outFlags[FLAG_INDEX_Z] = (out == 0);
        endcase

        case (mode)
        ALU1_CLR, // keep it
        ALU1_LD : outFlags[FLAG_INDEX_S] = flags[FLAG_INDEX_S];

        default : outFlags[FLAG_INDEX_S] = out[7];
        endcase
    end
endmodule

`endif