module CPU(
    input clk
);

    reg [5:0] pc = 0;
    reg [7:0] data = 0;
    reg [7:0] acc = 0;
    reg [1:0] instruction;

    reg [7:0] memory[0:63];
    initial begin
        memory[0] = 8'b00_00_1111; //    add %0f
        memory[1] = 8'b00_00_1110; // 1: add %0e
        memory[2] = 8'b01_00_0110; //    and %06
        memory[3] = 8'b11_00_0000; //    inc
        memory[4] = 8'b10_00_0001; //    jp 1
    end

    localparam ST_FETCH = 0;
    localparam ST_PROCESS = ST_FETCH + 1;
    reg [3:0] state = ST_FETCH;

    always @(posedge clk) begin
        if (state == ST_FETCH) begin
            data <= memory[pc];
            pc <= pc + 1;
            state <= state + 1;
        end
        else if (state == ST_PROCESS) begin
            case (data[7:6])
                2'b00: begin
                    acc <= acc + data[5:0];
                end
                2'b01: begin
                    acc <= acc & data[5:0];
                end
                2'b10: begin
                    pc <= data[5:0];
                end
                2'b11: begin
                    acc <= acc + 1;
                end
            endcase
            state <= ST_FETCH;
        end
    end

endmodule