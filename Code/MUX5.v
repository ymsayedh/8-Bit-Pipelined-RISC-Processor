module MUX5 (
    input wire [1:0] sel,
    input wire [7:0] alu_result,
    input wire [7:0] rd_data,
    input wire [7:0] in_port,
    input wire [7:0] immediate,

    output reg [7:0] wdata
);
always @(*) begin
    case(sel)
        2'b00: wdata = alu_result;
        2'b01: wdata = rd_data;
        2'b10: wdata = in_port;
        2'b11: wdata = immediate;
    endcase
end
endmodule

