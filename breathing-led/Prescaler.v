`ifndef PRESCALER
`define PRESCALER 1

module Prescaler #(
    parameter BITS = 22
) (
    input  clkIn,
    output clkOut
);

    reg[BITS:0] counter = 0;

    always @(posedge clkIn) begin
        counter <= counter + 1;
    end

    assign clkOut = counter[BITS];

endmodule

`endif