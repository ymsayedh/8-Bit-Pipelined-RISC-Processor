module IR (
    input  wire       clk,
    input  wire       load,
    input  wire [7:0] data_in,   // from  M[PC]

    output reg  [3:0] opcode,
    output reg  [1:0] ra,
    output reg  [1:0] rb
);

always @(posedge clk) begin
    if (load) begin
        opcode <= data_in[7:4];
        ra     <= data_in[3:2];
        rb     <= data_in[1:0];
    end
end

endmodule

