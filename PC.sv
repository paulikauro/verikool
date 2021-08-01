module PC (
    output [7:0] instructionPointer,
    input [7:0] branchTarget,
    input branchEnable,
    input clk,
    input rst
);
    logic [7:0] value;
    assign instructionPointer = value;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            value <= 0;
        end
        else if (clk) begin
            value <= branchEnable ? branchTarget : value + 1;
        end
    end
endmodule
