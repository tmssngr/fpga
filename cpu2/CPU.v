module CPU(
    input clk
);

    localparam FETCH = 3'b11_1;
    localparam ADD1 = 3'b00_0;
    localparam ADD2 = 3'b00_1;
    localparam AND1 = 3'b01_0;
    localparam AND2 = 3'b01_1;
    localparam INC = 3'b10_0;
    localparam JP = 3'b11_0;

    reg [7:0] pc;
    reg [7:0] acc;
    reg [7:0] data;
    reg [3:0] instruction;

    reg [7:0] memory[0:255];
    initial begin
        pc = 0;
        acc = 0;
        data = 0;
        instruction = FETCH;

        memory[0] = 8'h00; //    add
        memory[1] = 8'h0f; //        %0f
        memory[2] = 8'h00; // 2: add
        memory[3] = 8'h0e; //        %0e
        memory[4] = 8'h01; //    and
        memory[5] = 8'h06; //        %06
        memory[6] = 8'h02; //    inc
        memory[7] = 8'h03; //    jp
        memory[8] = 8'h02; //       2
    end

    always @(posedge clk) begin
        case (instruction)
        ADD1: begin
            data <= memory[pc];
            pc <= pc + 1;
            instruction <= instruction + 1;
        end
        ADD2: begin
            acc <= acc + data;
            instruction <= FETCH;
        end
        
        AND1: begin
            data <= memory[pc];
            pc <= pc + 1;
            instruction <= instruction + 1;
        end
        AND2: begin
            acc <= acc & data;
            instruction <= FETCH;
        end
        
        INC: begin
            acc <= acc + 1;
            instruction <= FETCH;
        end

        JP: begin
            pc <= memory[pc];
            instruction <= FETCH;
        end
        
        default: begin
            instruction <= {memory[pc][1:0], 1'b0};
            pc <= pc + 1;
        end
        endcase
    end

endmodule