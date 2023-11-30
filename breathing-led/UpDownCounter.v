`ifndef UP_DOWN_COUNTER
`define UP_DOWN_COUNTER 1

module UpDownCounter #(
    parameter BITS = 4
) (
    input               clk,
    input               dir, // 0..up, 1..down
    output [BITS - 1:0] out
);
    localparam allBits0 = {BITS{1'b0}};
    localparam allBits1 = {BITS{1'b1}};
    reg[BITS - 1:0] counter = allBits0;

    always @(posedge clk) begin
        counter <=
            ( dir == 0 & counter != allBits1 ? counter + 1 
            : dir == 1 & counter != allBits0 ? counter - 1 
            :                                  counter);
    end

    assign out = counter;
endmodule

`endif