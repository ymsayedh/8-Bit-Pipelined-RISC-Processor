module ForwardingUnit (
    // ID/EX stage register addresses
    input wire [1:0] id_ex_ra,
    input wire [1:0] id_ex_rb,
    
    // EX/MEM stage
    input wire ex_mem_reg_wr,
    input wire [1:0] ex_mem_wb_addr,
    input wire [7:0] ex_mem_alu_res,
    input wire [7:0] ex_mem_imm,
    input wire [1:0] ex_mem_wb_sel,

    // Data coming directly from Data Memory
    input wire [7:0] ex_mem_mem_data, 
    
    // MEM/WB stage
    input wire mem_wb_reg_wr,
    input wire [1:0] mem_wb_wb_addr,
    input wire [7:0] mem_wb_wb_data,
    
    // Original register file outputs
    input wire [7:0] rf_rdata1,
    input wire [7:0] rf_rdata2,
    
    // Forwarded outputs
    output reg [7:0] fwd_rdata1,
    output reg [7:0] fwd_rdata2
);

    // Helper to determine forwarding data from EX/MEM stage
    reg [7:0] ex_mem_fwd_data;
    always @(*) begin
        case(ex_mem_wb_sel)
            2'b00: ex_mem_fwd_data = ex_mem_alu_res;   // ALU result
            2'b01: ex_mem_fwd_data = ex_mem_mem_data;  // Forward Memory Data (LDD)
            2'b11: ex_mem_fwd_data = ex_mem_imm;       // Immediate (LDM)
            default: ex_mem_fwd_data = ex_mem_alu_res;
        endcase
    end

    always @(*) begin
        // --- Forward for rdata1 (ra) ---
        // REMOVED THE CHECK: && (ex_mem_wb_addr != 2'b11)
        if (ex_mem_reg_wr && (ex_mem_wb_addr == id_ex_ra)) begin
            fwd_rdata1 = ex_mem_fwd_data;
        end
        else if (mem_wb_reg_wr && (mem_wb_wb_addr == id_ex_ra)) begin
            fwd_rdata1 = mem_wb_wb_data;
        end
        else begin
            fwd_rdata1 = rf_rdata1;
        end
        
        // --- Forward for rdata2 (rb) ---
        // REMOVED THE CHECK: && (ex_mem_wb_addr != 2'b11)
        if (ex_mem_reg_wr && (ex_mem_wb_addr == id_ex_rb)) begin
            fwd_rdata2 = ex_mem_fwd_data;
        end
        else if (mem_wb_reg_wr && (mem_wb_wb_addr == id_ex_rb)) begin
            fwd_rdata2 = mem_wb_wb_data;
        end
        else begin
            fwd_rdata2 = rf_rdata2;
        end
    end

endmodule