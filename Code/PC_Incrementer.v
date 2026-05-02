module PC_Incrementer (
    input  wire [7:0] PC,
    output wire [7:0] PC_plus1,
    output wire [7:0] PC_plus2
);
assign PC_plus1 = PC + 8'd1;
assign PC_plus2 = PC + 8'd2;
endmodule
