module FETCH (
    input  wire clk,
    input  wire reset,
    input  wire pc_en,
    input  wire [1:0] pc_src_sel,
    input  wire intr,
    input  wire [7:0] reset_vector,
    input  wire [7:0] rdata2,
    input  wire [7:0] rd_data,

    output wire [3:0] opcode,
    output wire [1:0] ra,
    output wire [1:0] rb,
    output wire [7:0] immediate,
    output wire [7:0] PC_out
);

    wire [7:0] PC;
    wire [7:0] pc1, pc2, pc_next;
    wire [7:0] instr;
    wire [7:0] imm_raw;

    // PC
    PC pc0(clk, reset, pc_en, pc_next, intr, reset_vector, PC);

    // PC +1/+2
    PC_Incrementer inc(PC, pc1, pc2);

    // Instruction Memory
    InstructionMemory imem(PC, 1'b1, instr, imm_raw);

    // Decode to check if 2-byte instruction
    wire is_two_byte;
    assign is_two_byte = (instr[7:4] == 4'd12);

    // PC selection logic
    assign pc_next = (pc_src_sel == 2'b00) ? (is_two_byte ? pc2 : pc1) :
                     (pc_src_sel == 2'b01) ? pc2 :
                     (pc_src_sel == 2'b10) ? rdata2 : rd_data;

    // --- FIX START: Remove IR instance and use combinational assignments ---
    
    // IR ir(clk, 1'b1, instr, opcode, ra, rb); // <--- DELETE THIS LINE
    
    assign opcode = instr[7:4];
    assign ra     = instr[3:2];
    assign rb     = instr[1:0];
    
    // --- FIX END ---

    // Immediate only valid for 2-byte instructions
    assign immediate = is_two_byte ? imm_raw : 8'b0;

    // Output PC for debugging
    assign PC_out = PC;

endmodule