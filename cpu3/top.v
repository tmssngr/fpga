module top(
    input wire clk,
    output wire[5:0] leds
);

    CPU cpu(
        .clk(clk)
    );

endmodule