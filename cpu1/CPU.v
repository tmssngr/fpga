module CPU(
    input clk
);

    localparam FETCH = 9'b1_0000_0000;

    reg [7:0] pc;
    reg [7:0] acc;
    reg [8:0] instruction;

    reg [7:0] memory[0:255];
    initial begin
        pc = 0;
        acc = 0;
        instruction = FETCH;

        memory[0] = 8'b00_00_1111; //    add %0f
        memory[1] = 8'b00_00_1110; // 1: add %0e
        memory[2] = 8'b01_00_0110; //    and %06
        memory[3] = 8'b11_00_0000; //    inc
        memory[4] = 8'b10_00_0000; //    jp
        memory[5] = 8'h01;         //       1
    end

    always @(posedge clk) begin
        case (instruction[8:6])
        3'b0_00: begin
            acc <= acc + instruction[5:0];
            instruction <= FETCH;
        end
        
        3'b0_01: begin
            acc <= acc & instruction[5:0];
            instruction <= FETCH;
        end
        
        3'b0_10: begin
            pc <= memory[pc];
            instruction <= FETCH;
        end
        
        3'b0_11: begin
            acc <= acc + 1;
            instruction <= FETCH;
        end
        
        default: begin
            instruction <= {1'b0, memory[pc]};
            pc <= pc + 1;
        end
        endcase
    end

endmodule