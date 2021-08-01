module Memory(
    input [7:0] address,
    input [7:0] in,
    output [7:0] out,
    input writeEnable,
    input clk
);
    logic [7:0] memory[256];
    assign out = memory[address];

    always_ff @(posedge clk) begin
        if (writeEnable) begin
            memory[address] <= in;
        end
    end
endmodule
