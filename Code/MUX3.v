module MUX3 (
    input wire [1:0] sel,
    input wire [7:0] rdata2,
    input wire [7:0] imm,
    output reg [7:0] B_out
);
always @(*) begin
    case(sel)
        2'b00: B_out = rdata2;
        2'b01: B_out = imm;
        2'b10: B_out = 8'd1;
        2'b11: B_out = 8'd0;
    endcase
end
endmodule

