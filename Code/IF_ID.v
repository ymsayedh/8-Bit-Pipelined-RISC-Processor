module IF_ID (
    input wire clk,
    input wire reset,
    input wire flush,

    input wire [3:0] opcode_in,
    input wire [1:0] ra_in,
    input wire [1:0] rb_in,
    input wire [7:0] immediate_in,

    output reg [3:0] opcode,
    output reg [1:0] ra,
    output reg [1:0] rb,
    output reg [7:0] immediate
);

always @(posedge clk or posedge reset) begin
    if (reset || flush) begin
        opcode <= 0;
    end else begin
        opcode <= opcode_in;
        ra <= ra_in;
        rb <= rb_in;
        immediate <= immediate_in;
    end
end

endmodule

