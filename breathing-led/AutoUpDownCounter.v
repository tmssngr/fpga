`ifndef AUTO_UP_DOWN_COUNTER
`define AUTO_UP_DOWN_COUNTER 1

`include "UpDownCounter.v"

module AutoUpDownCounter #(
    parameter BITS = 4
) (
    input               clk,
    output [BITS - 1:0] out,
    output              outDir
);

    reg  dir = 0;

    UpDownCounter #(
        .BITS(BITS)
    ) udc(
        .clk(clk),
        .dir(dir),
        .out(out)
    );

    always @(negedge clk) begin
        if (out == {BITS{1'b1}}) begin
            dir <= 1;
        end

        if (out == {BITS[1'b0]}) begin
            dir <= 0;
        end
    end

    assign  outDir = dir;

endmodule

`endif