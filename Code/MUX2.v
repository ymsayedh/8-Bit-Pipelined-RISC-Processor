module MUX2 (
    input wire [1:0] sel,
    input wire [7:0] rdata1,
    input wire [7:0] rdata2,
    input wire [7:0] PC,
    output reg [7:0] A_out
);
always @(*) begin
    case(sel)
        2'b00: A_out = rdata1;
        2'b01: A_out = rdata2;
        2'b10: A_out = PC;
        2'b11: A_out = 8'b0;
    endcase
end
endmodule

