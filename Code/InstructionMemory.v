module InstructionMemory (
    input  wire [7:0] address,
    input  wire       rd_en,

    output wire [7:0] rdata,
    output wire [7:0] immediate
);

reg [7:0] mem [0:255];
integer i;

// ABSOLUTE MINIMAL TEST: Just one LDM instruction
initial begin
    // Initialize everything to NOP
    for (i = 0; i < 256; i = i + 1) begin
        mem[i] = 8'h00;
    end
    
    // Only one instruction: LDM R1, #5
// Inside InstructionMemory.v initial block:

    

end

// Combinational read
assign rdata     = (rd_en) ? mem[address] : 8'b0;
assign immediate = (rd_en) ? mem[address + 8'd1] : 8'b0;

endmodule