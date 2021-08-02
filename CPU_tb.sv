`timescale 1ps/1ps
module CPU_tb;
    reg [7:0] programMem [256];
    wire [7:0] instPtr;
    wire [7:0] inst = programMem[instPtr];

    reg clk;
    initial clk = 0;
    always #10 clk = ~clk;

    reg rst;

    wire [7:0] memAddress, memIn, memOut;
    wire memWrEnable;

    CPU cpu(
        .instAddress(instPtr),
        .instruction(inst),
        .memAddress(memAddress),
        .memIn(memIn),
        .memOut(memOut),
        .memWrEnable(memWrEnable),
        .clk(clk),
        .rst(rst)
    );

    Memory memory(
        .address(memAddress),
        .in(memIn),
        .out(memOut),
        .writeEnable(memWrEnable),
        .clk(clk)
    );

    initial begin
        for (logic [7:0] i = 0; i < 255; i++) begin
            programMem[i] = 0;
        end
        $dumpfile("stuff.vcd");
        $dumpvars(0, cpu);
        $readmemb("fib.txt", programMem);
        rst = 1;
        #5 rst = 0;
        #5 rst = 1;
        $display("reset complete");
    end

    reg [7:0] ctr;
    initial ctr = 0;

    always @(posedge clk) begin : simulatePeripherals
        if (instPtr == 8'hFF) begin
            $display("halted");
            $finish;
        end
        //$display("ctr = %d, ip = %d, inst = %x", ctr, instPtr, inst);
        ctr = ctr + 1;
        if (ctr == 255) begin
            $display("ctr reached 255");
            //$finish;
        end
        if (memWrEnable) begin
            if (memAddress == 8'hFF) $display("output: %d", memIn);
        end
    end
endmodule
