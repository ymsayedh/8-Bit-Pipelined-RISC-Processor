module PC (
    input  wire        clk,
    input  wire        reset,
    input  wire        pc_en,          // stall control
    input  wire [7:0]  pc_next,        // from MUX1

    // interrupt support
    input  wire        intr,           // external interrupt
    input  wire [7:0]  reset_vector,   // M[0]
    
    output reg  [7:0]  PC
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        PC <= reset_vector;     // PC ? M[0]
    end 
    else if (intr) begin
        PC <= 8'h01;            // PC ? M[1] interrupt vector
    end
    else if (pc_en) begin
        PC <= pc_next;
    end
end

endmodule

