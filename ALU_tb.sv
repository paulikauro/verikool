`timescale 1ps/1ps
module ALU_tb;
    logic [7:0] a, b, out;
    logic [1:0] op;
    wire zero, carry;
    ALU alu(
        .a(a),
        .b(b),
        .out(out),
        .op(op),
        .zero(zero),
        .carry(carry)
    );
    initial begin
        $dumpfile("stuff.vcd");
        $dumpvars(0, alu);
        a = 3;
        b = 5;
        op = alu.SUB;
        // carry should be off
        #5 op = alu.ADD;
        #5 op = alu.NAND;
        // test zero flag; should become on
        #5 op = alu.SUB;
        b = 3;
        // test carry flag; should become on
        #5 b = 2;
        #5 $finish;
    end
endmodule
