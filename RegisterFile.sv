module RegisterFile (
    input [7:0] in,
    output [7:0] aOut,
    output [7:0] bOut,
    input [1:0] writeAddress,
    input [1:0] aAddress,
    input [1:0] bAddress,
    input writeEnable,
    input clk
);
    logic [7:0] buffer [3:0];

    assign aOut = buffer[aAddress];
    assign bOut = buffer[bAddress];

    always_ff @(posedge clk) begin
        if (writeEnable) begin
            buffer[writeAddress] <=  in;
        end
    end
endmodule
