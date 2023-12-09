module top (
    input  wire clk,
    input  wire btn,
    output reg[5:0] led
);

    localparam bits = 19;
    reg[bits:0] counter = 0;
    always @(posedge clk) begin
        counter <= counter + 1;
    end

    wire btnDir;
    Debouncer btnD(
        .clk(clk),
        .in(btn),
        .out(btnDir)
    );

    reg Dir = 0;
    always @(posedge btnDir) begin
        Dir <= ~Dir;
    end

    localparam flashBits = 5;
    localparam start = 9;
    reg[flashBits - 1:0] flashCounter = 0;
    reg dir = 0;
    always @(posedge counter[bits]) begin
        flashCounter <= flashCounter + 1;

        if (flashCounter == {flashBits{1'b0}}) begin
            dir <= Dir;
            led <= {6{1'b1}};
        end
        if (flashCounter == start + 0) led[dir ? 0 : 5] <= 0;
        if (flashCounter == start + 1) led[dir ? 1 : 4] <= 0;
        if (flashCounter == start + 2) led[dir ? 2 : 3] <= 0;
        if (flashCounter == start + 3) led[dir ? 3 : 2] <= 0;
        if (flashCounter == start + 4) led[dir ? 4 : 1] <= 0;
        if (flashCounter == start + 5) led[dir ? 5 : 0] <= 0;
    end

endmodule
