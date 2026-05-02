module EX_MEM_Extended (
    input wire clk,
    input wire reset,

    // Data inputs
    input wire [7:0] alu_res_in,
    input wire [7:0] B_in,
    input wire [1:0] wb_addr_in,
    input wire [7:0] imm_in,

    // Control inputs
    input wire mem_rd_in, 
    input wire mem_wr_in, 
    input wire reg_wr_in,
    input wire [1:0] wb_sel_in,
    input wire [1:0] mem_addr_sel_in,
    input wire [1:0] mem_data_sel_in,
    input wire out_en_in,

    // Data outputs
    output reg [7:0] alu_res,
    output reg [7:0] B_out,
    output reg [1:0] wb_addr,
    output reg [7:0] imm_out,

    // Control outputs
    output reg mem_rd, 
    output reg mem_wr, 
    output reg reg_wr,
    output reg [1:0] wb_sel,
    output reg [1:0] mem_addr_sel,
    output reg [1:0] mem_data_sel,
    output reg out_en
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        alu_res <= 0;
        B_out <= 0;
        wb_addr <= 0;
        imm_out <= 0;
        mem_rd <= 0; 
        mem_wr <= 0; 
        reg_wr <= 0;
        wb_sel <= 0;
        mem_addr_sel <= 0;
        mem_data_sel <= 0;
        out_en <= 0;
    end else begin
        alu_res <= alu_res_in;
        B_out <= B_in;
        wb_addr <= wb_addr_in;
        imm_out <= imm_in;
        mem_rd <= mem_rd_in;
        mem_wr <= mem_wr_in;
        reg_wr <= reg_wr_in;
        wb_sel <= wb_sel_in;
        mem_addr_sel <= mem_addr_sel_in;
        mem_data_sel <= mem_data_sel_in;
        out_en <= out_en_in;
    end
end

endmodule