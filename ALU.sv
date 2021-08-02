module ALU(
    input [7:0] a,
    input [7:0] b,
    output [7:0] out,
    input [1:0] op,
    output zero,
    output logic carry
);
    typedef enum logic [1:0] { SUB, ADD, NAND } op_type;

    // 9 bit result to capture carry out
    logic [8:0] result;
    assign out = result[7:0];
    assign zero = out == 0;

    always_comb begin
        case (op)
            SUB: begin
                // or a - b?
                result = b - a;
                carry = ~(result[8]);
            end
            ADD: begin
                result = a + b;
                carry = result[8];
            end
            NAND: begin
                // zero-extend result
                result = {1'b0, ~(a & b)};
                carry = 0;
            end
            default: begin
                result = 0;
                carry = 0;
            end
        endcase
    end
endmodule
