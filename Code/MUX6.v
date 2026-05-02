module MUX6 (
    input wire [1:0] sel,
    input wire [7:0] rdata2,
    input wire [7:0] alu_res,
    input wire [7:0] pc1,
    input wire [7:0] flags,
    output reg [7:0] write_data
);
always @(*) begin
    case(sel)
        2'b00: write_data = rdata2;
        2'b01: write_data = alu_res;
        2'b10: write_data = pc1;
        2'b11: write_data = flags;
    endcase
end
endmodule

