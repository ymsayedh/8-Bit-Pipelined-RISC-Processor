module MUX4 (
    input wire [1:0] sel,
    input wire [7:0] sp,
    input wire [7:0] ea,
    input wire [7:0] rdata1,
    input wire [7:0] alu_res,
    output reg [7:0] addr
);
always @(*) begin
    case(sel)
        2'b00: addr = sp;
        2'b01: addr = ea;
        2'b10: addr = rdata1;
        2'b11: addr = alu_res;
    endcase
end
endmodule

