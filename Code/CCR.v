module CCR (
    input wire clk,
    input wire reset,
    input wire we,
    input wire Z_in,
    input wire N_in,
    input wire C_in,
    input wire V_in,
    
    output reg Z,
    output reg N,
    output reg C,
    output reg V
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        Z <= 0;
        N <= 0;
        C <= 0;
        V <= 0;
    end else if (we) begin
        Z <= Z_in;
        N <= N_in;
        C <= C_in;
        V <= V_in;
    end
end

endmodule