module MEM_WB_Extended (
    input wire clk,
    input wire reset,
    
    // Data inputs
    input wire [7:0] imm_in,
    input wire [7:0] mem_data_in,
    input wire [7:0] alu_res_in,
    input wire [1:0] wb_addr_in,
    
    // Control inputs
    input wire reg_wr_in,
    input wire [1:0] wb_sel_in,

    // Data outputs
    output reg [7:0] mem_data,
    output reg [7:0] alu_res,
    output reg [1:0] wb_addr,
    output reg [7:0] imm,
    
    // Control outputs
    output reg reg_wr,
    output reg [1:0] wb_sel
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        mem_data <= 0;
        alu_res <= 0;
        wb_addr <= 0;
        imm <= 0;
        reg_wr <= 0;
        wb_sel <= 0;
    end else begin
        mem_data <= mem_data_in;
        alu_res <= alu_res_in;
        wb_addr <= wb_addr_in;
        imm <= imm_in;
        reg_wr <= reg_wr_in;
        wb_sel <= wb_sel_in;
    end
end

endmodule