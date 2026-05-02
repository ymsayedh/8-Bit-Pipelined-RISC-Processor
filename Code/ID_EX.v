module ID_EX_Extended (
    input wire clk,
    input wire reset,

    // Data inputs
    input wire [3:0] opcode_in,
    input wire [1:0] ra_in, rb_in,
    input wire [7:0] A_in, B_in,
    input wire [7:0] imm_in,

    // Control inputs
    input wire [3:0] alu_op_in,
    input wire [1:0] alu_srcA_in,
    input wire [1:0] alu_srcB_in,
    input wire rf_we_in,
    input wire [1:0] rf_waddr_in,
    input wire [1:0] wb_sel_in,
    input wire mem_rd_in,
    input wire mem_wr_in,
    input wire [1:0] mem_addr_sel_in,
    input wire [1:0] mem_data_sel_in,
    input wire ccr_we_in,
    input wire out_en_in,
    
    // --- NEW: Stack Pointer Controls Inputs ---
    input wire sp_inc_in,
    input wire sp_dec_in,
    // ------------------------------------------

    // Data outputs
    output reg [3:0] opcode,
    output reg [1:0] ra, rb,
    output reg [7:0] A, B, imm,

    // Control outputs
    output reg [3:0] alu_op,
    output reg [1:0] alu_srcA,
    output reg [1:0] alu_srcB,
    output reg rf_we,
    output reg [1:0] rf_waddr,
    output reg [1:0] wb_sel,
    output reg mem_rd,
    output reg mem_wr,
    output reg [1:0] mem_addr_sel,
    output reg [1:0] mem_data_sel,
    output reg ccr_we,
    output reg out_en,

    // --- NEW: Stack Pointer Controls Outputs ---
    output reg sp_inc,
    output reg sp_dec
    // -------------------------------------------
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        opcode <= 0;
        ra <= 0;
        rb <= 0;
        A <= 0;
        B <= 0;
        imm <= 0;
        alu_op <= 0;
        alu_srcA <= 0;
        alu_srcB <= 0;
        rf_we <= 0;
        rf_waddr <= 0;
        wb_sel <= 0;
        mem_rd <= 0;
        mem_wr <= 0;
        mem_addr_sel <= 0;
        mem_data_sel <= 0;
        ccr_we <= 0;
        out_en <= 0;
        
        // Reset New Signals
        sp_inc <= 0;
        sp_dec <= 0;
        
    end else begin
        opcode <= opcode_in;
        ra <= ra_in;
        rb <= rb_in;
        A <= A_in;
        B <= B_in;
        imm <= imm_in;
        alu_op <= alu_op_in;
        alu_srcA <= alu_srcA_in;
        alu_srcB <= alu_srcB_in;
        rf_we <= rf_we_in;
        rf_waddr <= rf_waddr_in;
        wb_sel <= wb_sel_in;
        mem_rd <= mem_rd_in;
        mem_wr <= mem_wr_in;
        mem_addr_sel <= mem_addr_sel_in;
        mem_data_sel <= mem_data_sel_in;
        ccr_we <= ccr_we_in;
        out_en <= out_en_in;
        
        // Pass New Signals
        sp_inc <= sp_inc_in;
        sp_dec <= sp_dec_in;
    end
end

endmodule