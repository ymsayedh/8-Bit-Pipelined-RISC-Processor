module DataMemory (
    input wire clk,
    input wire [7:0] address,
    input wire [7:0] write_data,
    input wire rd_en,
    input wire wr_en,
    output wire [7:0] rd_data
);

reg [7:0] mem [0:255];

assign rd_data = (rd_en) ? mem[address] : 8'b0;

always @(posedge clk) begin
    if (wr_en)
        mem[address] <= write_data;
end

endmodule

