module Debouncer #(
    parameter BITS = 8
) (
    input  clk,
    input  in,
    output out
);

    reg[BITS:0] counter = 0;
    reg      prevValue = 0;
    reg      outValue = 0;

    always @(posedge clk) begin
        if (in != prevValue) begin
            counter <= 0;
            prevValue <= in;
        end
        else if (counter[BITS] == 0) begin
            counter <= counter + 1;
        end
        else begin
            outValue <= prevValue;
        end
    end

    assign out = outValue;

endmodule