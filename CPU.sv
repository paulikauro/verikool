// or datapath?
module CPU(
    output [7:0] instAddress,
    input [7:0] instruction,
    output [7:0] memAddress, memIn,
    output memWrEnable,
    input [7:0] memOut,
    input clk,
    input rst
);
    logic [7:0] busA, busB;
    logic [1:0] aluOp;
    // from ALU
    logic zero, carry;
    // actual flag registers
    logic zeroFlag, carryFlag;
    // control signals
    logic updateFlags;
    logic regWriteEnable;
    logic memWriteEnable;
    logic [2:0] regWriteSource;
    logic branchEnable;
    // load immediate and branch and link write to reg 3 implicitly
    logic implicitRegAddress3;

    // opcode is in the least significant bits
    wire logic [3:0] op = (instruction[0] == 0) ? LIM : instruction[3:0];
    wire logic [7:0] immediate = sign_extend(instruction[7:1]);
    wire logic [1:0] source = instruction[5:4];
    wire logic [1:0] destination = instruction[7:6];

    typedef enum logic [2:0] { SRC_MOV, SRC_ALU, SRC_PC, SRC_MEM, SRC_IMM } regWriteSourceType;
    typedef enum logic [1:0] { COND_LT, COND_GT, COND_EQ, COND_ALWAYS } branchConditionType;

    always_comb begin : decodeInstruction
        // defaults
        updateFlags = 0;
        regWriteEnable = 1;
        memWriteEnable = 0;
        implicitRegAddress3 = 0;
        regWriteSource = SRC_ALU;
        branchEnable = 0;
        aluOp = alu.ADD;
        case (op)
            LIM: begin
                implicitRegAddress3 = 1;
                regWriteSource = SRC_IMM;
            end
            LOAD: begin
                regWriteSource = SRC_MEM;
            end
            STORE: begin
                memWriteEnable = 1;
                regWriteEnable = 0;
            end
            CMP: begin
                aluOp = alu.SUB;
                regWriteEnable = 0;
                updateFlags = 1;
            end
            BRL: begin
                implicitRegAddress3 = 1;
                regWriteSource = SRC_PC;
                // condition bits are stored in the destination field
                case (destination)
                    COND_LT: branchEnable = ~carryFlag && ~zeroFlag;
                    COND_GT: branchEnable = carryFlag && ~zeroFlag;
                    COND_EQ: branchEnable = zeroFlag;
                    COND_ALWAYS: branchEnable = 1;
                endcase
            end
            SUB: begin
                aluOp = alu.SUB;
            end
            ADD: begin
                aluOp = alu.ADD;
            end
            NAND: begin
                aluOp = alu.NAND;
            end
            MOV: begin
                regWriteSource = SRC_MOV;
            end
            default: $display("unknown op %d", op); // impossible
        endcase
    end

    // A = source, pointer
    wire logic [1:0] regAddrA = source;
    // B = destination, condition
    wire logic [1:0] regAddrB = destination;
    wire logic [1:0] regAddrW = implicitRegAddress3 ? 3 : destination;
    logic [7:0] aluOut;
    logic [7:0] instructionPointer;
    logic [7:0] busOut;
    assign instAddress = instructionPointer;

    always_comb begin : selectRegWriteSource
        case (regWriteSource)
            SRC_IMM: busOut = immediate;
            SRC_PC: busOut = instructionPointer + 1;
            SRC_ALU: busOut = aluOut;
            SRC_MEM: busOut = memOut;
            SRC_MOV: busOut = busA;
            default: busOut = 0; // impossible
        endcase
    end

    ALU alu(
        .a(busA),
        .b(busB),
        .out(aluOut),
        .op(aluOp),
        .zero(zero),
        .carry(carry)
    );
    RegisterFile registers(
        .in(busOut),
        .aOut(busA),
        .bOut(busB),
        .writeAddress(regAddrW),
        .aAddress(regAddrA),
        .bAddress(regAddrB),
        .writeEnable(regWriteEnable),
        .clk(clk)
    );
    assign memAddress = busA;
    assign memIn = busB;
    assign memWrEnable = memWriteEnable;
    PC pc(
        .instructionPointer(instructionPointer),
        .branchTarget(busA),
        .branchEnable(branchEnable),
        .clk(clk),
        .rst(rst)
    );

    always_ff @(posedge clk) begin
        if (updateFlags) begin
            carryFlag <= carry;
            zeroFlag <= zero;
        end
        //$display("regs: r0 = %d, r1 = %d, r2 = %d, r3 = %d", registers.buffer[0], registers.buffer[1], registers.buffer[2], registers.buffer[3]);
        //if (op == BRL) $display("branch!");
    end

endmodule

function logic [7:0] sign_extend(input [6:0] number);
    begin
        sign_extend = {number[6], number};
    end
endfunction

typedef enum logic [3:0] {
    LIM = 0,
    LOAD = 1,
    STORE = 3,
    CMP = 5,
    BRL = 7,
    SUB = 9,
    ADD = 11,
    NAND = 13,
    MOV = 15
} opcode;
