module MUX1 (
    input  wire [1:0] sel,
    input  wire [7:0] pc1,
    input  wire [7:0] pc2,
    input  wire [7:0] rdata2,
    input  wire [7:0] rd_data,

    output reg  [7:0] pc_next
);
always @(*) begin
    case(sel)
        2'b00: pc_next = pc1;
        2'b01: pc_next = pc2;
        2'b10: pc_next = rdata2;
        2'b11: pc_next = rd_data;
        default: pc_next = pc1;
    endcase
end
endmodule

