module OutputPort (
    input wire clk,
    input wire reset,
    input wire out_en,
    input wire [7:0] data_in,
    output reg [7:0] OUT_PORT
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        OUT_PORT <= 8'h00;
    end else if (out_en) begin
        OUT_PORT <= data_in;
    end
end

endmodule