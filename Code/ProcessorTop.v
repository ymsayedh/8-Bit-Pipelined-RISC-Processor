module ProcessorTop(
    input wire clk,
    input wire reset,
    input wire [7:0] IN_PORT,
    output wire [7:0] OUT_PORT
);

/* =================== WIRES =================== */

// Control → Fetch
wire pc_en_cu;
wire [1:0] pc_src;

// --- FIX 1: FLUSH SIGNAL ---
wire if_id_flush;
assign if_id_flush = (pc_src != 2'b00); 
// ---------------------------

// Fetch → IF/ID
wire [3:0] opcode_f;
wire [1:0] ra_f, rb_f;
wire [7:0] imm_f;
wire [7:0] PC_f;

// IF/ID → Decode
wire [3:0] opcode_d;
wire [1:0] ra_d, rb_d;
wire [7:0] imm_d;

// Register File (raw outputs)
wire [7:0] rdata1_raw, rdata2_raw, sp;

// Forwarded register values (Output of Forwarding Unit)
wire [7:0] rdata1, rdata2;

// Control signals
wire [3:0] alu_op_cu;
wire [1:0] alu_srcA_cu, alu_srcB_cu;
wire rf_we_cu, mem_rd_cu, mem_wr_cu, ccr_we_cu, out_en_cu;
wire [1:0] rf_waddr_cu, wb_sel_cu;
wire [1:0] mem_addr_sel_cu, mem_data_sel_cu;

// --- Stack Pointer Controls ---
wire sp_inc_cu, sp_dec_cu;
// ------------------------------

// Flags
wire Z, N, C, V;

// ID/EX
wire [7:0] A_e, B_e, imm_e;
wire [3:0] opcode_e;
wire [1:0] ra_e, rb_e;
wire [3:0] alu_op_e;
wire [1:0] alu_srcA_e, alu_srcB_e;
wire rf_we_e, mem_rd_e, mem_wr_e, ccr_we_e, out_en_e;
wire [1:0] rf_waddr_e, wb_sel_e;
wire [1:0] mem_addr_sel_e, mem_data_sel_e;

// SP Controls in Execute (Passed directly for now)
wire sp_inc_e, sp_dec_e;


// Execute
wire [7:0] alu_inA, alu_inB, alu_res;
wire Z_in, N_in, C_in, V_in;

// EX/MEM
wire [7:0] alu_m, B_m;
wire mem_rd_m, mem_wr_m, reg_wr_m, out_en_m;
wire [1:0] wb_addr_m;
wire [1:0] wb_sel_m;
wire [1:0] mem_addr_sel_m, mem_data_sel_m;
wire [7:0] imm_m;

// Memory
wire [7:0] mem_addr, mem_wdata, rd_data;

// MEM/WB
wire [7:0] memwb_mem, memwb_alu, memwb_imm;
wire [1:0] memwb_wb_addr;
wire memwb_reg_wr;
wire [1:0] memwb_wb_sel;

// Writeback
wire [7:0] wb_data;

/* =================== JUMP FORWARDING LOGIC =================== */
// Solves LDM -> JMP data hazard in Decode stage
reg [7:0] jump_target;

always @(*) begin
    // Default: Read directly from Register File
    jump_target = rdata2_raw;

    // 1. Check EXECUTE Stage (Forward from ALU or Immediate)
    if (rf_we_e && (rf_waddr_e == rb_d)) begin
        if (wb_sel_e == 2'b11)      jump_target = imm_e;
        else if (wb_sel_e == 2'b00) jump_target = alu_res;
    end
    
    // 2. Check MEMORY Stage (Forward from Mem, ALU, or Imm)
    else if (reg_wr_m && (wb_addr_m == rb_d)) begin
        if (wb_sel_m == 2'b01)      jump_target = rd_data;
        else if (wb_sel_m == 2'b11) jump_target = imm_m;
        else                        jump_target = alu_m;
    end
    
    // 3. Check WRITEBACK Stage
    else if (memwb_reg_wr && (memwb_wb_addr == rb_d)) begin
        jump_target = wb_data;
    end
end

/* =================== FETCH =================== */

FETCH fetch(
    .clk(clk), 
    .reset(reset),
    .pc_en(pc_en_cu), 
    .pc_src_sel(pc_src),
    .intr(1'b0), 
    .reset_vector(8'h00),
    
    .rdata2(jump_target), // Use the smart forwarded wire
    
    .rd_data(rd_data),
    .opcode(opcode_f), 
    .ra(ra_f), 
    .rb(rb_f), 
    .immediate(imm_f),
    .PC_out(PC_f)
);

/* =================== IF/ID =================== */

IF_ID ifid(
    .clk(clk), 
    .reset(reset), 
    .flush(if_id_flush), // Connected Flush logic
    .opcode_in(opcode_f), 
    .ra_in(ra_f), 
    .rb_in(rb_f), 
    .immediate_in(imm_f),
    .opcode(opcode_d), 
    .ra(ra_d), 
    .rb(rb_d), 
    .immediate(imm_d)
);

/* =================== REGISTER FILE =================== */

RegisterFile rf(
    .clk(clk), 
    .reset(reset),
    .we(memwb_reg_wr), 
    .waddr(memwb_wb_addr), 
    .wdata(wb_data),
    
    .sp_inc(sp_inc_e), // SP controls
    .sp_dec(sp_dec_e),
    
    .raddr1(ra_d), 
    .raddr2(rb_d),
    .rdata1(rdata1_raw), // Output Raw
    .rdata2(rdata2_raw), // Output Raw
    .sp_value(sp)
);

/* =================== FORWARDING UNIT =================== */

ForwardingUnit fwd_unit(
    // --- CHANGED: Use EXECUTE stage addresses ---
    .id_ex_ra(ra_e),
    .id_ex_rb(rb_e),
    // --------------------------------------------

    .ex_mem_reg_wr(reg_wr_m),
    .ex_mem_wb_addr(wb_addr_m),
    .ex_mem_alu_res(alu_m),
    .ex_mem_imm(imm_m),
    .ex_mem_wb_sel(wb_sel_m),
    .ex_mem_mem_data(rd_data), 
    
    .mem_wb_reg_wr(memwb_reg_wr),
    .mem_wb_wb_addr(memwb_wb_addr),
    .mem_wb_wb_data(wb_data),
    
    // --- CHANGED: Use Pipeline Registers (A/B) as defaults ---
    .rf_rdata1(A_e),
    .rf_rdata2(B_e),
    // ---------------------------------------------------------
    
    .fwd_rdata1(rdata1),
    .fwd_rdata2(rdata2)
);

/* =================== CONTROL UNIT =================== */

ControlUnit CU(
    .opcode(opcode_d), 
    .ra(ra_d), 
    .rb(rb_d), 
    .Z(Z), 
    .N(N), 
    .C(C), 
    .V(V),
    .pc_en(pc_en_cu), 
    .pc_src(pc_src),
    .alu_op(alu_op_cu), 
    .alu_srcA(alu_srcA_cu), 
    .alu_srcB(alu_srcB_cu),
    .rf_we(rf_we_cu), 
    .rf_waddr(rf_waddr_cu), 
    .wb_sel(wb_sel_cu),
    .mem_rd(mem_rd_cu), 
    .mem_wr(mem_wr_cu),
    .mem_addr_sel(mem_addr_sel_cu), 
    .mem_data_sel(mem_data_sel_cu),
    .ccr_we(ccr_we_cu),
    .out_en(out_en_cu),
    .sp_inc(sp_inc_cu),
    .sp_dec(sp_dec_cu)
);

/* =================== ID/EX (Extended) =================== */

ID_EX_Extended idex(
    .clk(clk), 
    .reset(reset),
    .opcode_in(opcode_d), 
    .ra_in(ra_d), 
    .rb_in(rb_d),
    
    // --- CHANGED: Latch RAW values into pipeline ---
    .A_in(rdata1_raw), 
    .B_in(rdata2_raw),
    // -----------------------------------------------

    .imm_in(imm_d),
    .alu_op_in(alu_op_cu),
    .alu_srcA_in(alu_srcA_cu),
    .alu_srcB_in(alu_srcB_cu),
    .rf_we_in(rf_we_cu),
    .rf_waddr_in(rf_waddr_cu),
    .wb_sel_in(wb_sel_cu),
    .mem_rd_in(mem_rd_cu),
    .mem_wr_in(mem_wr_cu),
    .mem_addr_sel_in(mem_addr_sel_cu),
    .mem_data_sel_in(mem_data_sel_cu),
    .ccr_we_in(ccr_we_cu),
    .out_en_in(out_en_cu),
    .sp_inc_in(sp_inc_cu),
    .sp_dec_in(sp_dec_cu),
    .sp_inc(sp_inc_e),     // Note: .sp_inc matches output name in ID_EX
    .sp_dec(sp_dec_e),     // Note: .sp_dec matches output name in ID_EX
    .opcode(opcode_e), 
    .ra(ra_e), 
    .rb(rb_e), 
    .A(A_e), 
    .B(B_e), 
    .imm(imm_e),
    .alu_op(alu_op_e),
    .alu_srcA(alu_srcA_e),
    .alu_srcB(alu_srcB_e),
    .rf_we(rf_we_e),
    .rf_waddr(rf_waddr_e),
    .wb_sel(wb_sel_e),
    .mem_rd(mem_rd_e),
    .mem_wr(mem_wr_e),
    .mem_addr_sel(mem_addr_sel_e),
    .mem_data_sel(mem_data_sel_e),
    .ccr_we(ccr_we_e),
    .out_en(out_en_e)
);

/* =================== EXECUTE =================== */

MUX2 muxA(
    .sel(alu_srcA_e), 
    // --- CHANGED: Use Forwarded Data ---
    .rdata1(rdata1), 
    .rdata2(rdata2), 
    // -----------------------------------
    .PC(PC_f), // PC for CALL
    .A_out(alu_inA)
);

MUX3 muxB(
    .sel(alu_srcB_e), 
    // --- CHANGED: Use Forwarded Data ---
    .rdata2(rdata2), 
    // -----------------------------------
    .imm(imm_e), 
    .B_out(alu_inB)
);

ALU alu(
    .A(alu_inA), 
    .B(alu_inB), 
    .carry_in(C), 
    .alu_op(alu_op_e),
    .result(alu_res), 
    .Z(Z_in), 
    .N(N_in), 
    .C(C_in), 
    .V(V_in)
);

CCR ccr(
    .clk(clk), 
    .reset(reset), 
    .we(ccr_we_e), 
    .Z_in(Z_in), 
    .N_in(N_in), 
    .C_in(C_in), 
    .V_in(V_in), 
    .Z(Z), 
    .N(N), 
    .C(C), 
    .V(V)
);

/* =================== EX/MEM =================== */

EX_MEM_Extended exmem(
    .clk(clk), 
    .reset(reset),
    .alu_res_in(alu_res), 
    
    // --- CHANGED: Feed Forwarded Data to Memory Stage ---
    .B_in(rdata2), 
    // ----------------------------------------------------
    
    .wb_addr_in(rf_waddr_e),
    .mem_rd_in(mem_rd_e), 
    .mem_wr_in(mem_wr_e), 
    .reg_wr_in(rf_we_e), 
    .wb_sel_in(wb_sel_e),
    .mem_addr_sel_in(mem_addr_sel_e),
    .mem_data_sel_in(mem_data_sel_e),
    .imm_in(imm_e),
    .out_en_in(out_en_e),
    .alu_res(alu_m), 
    .B_out(B_m), 
    .wb_addr(wb_addr_m),
    .mem_rd(mem_rd_m), 
    .mem_wr(mem_wr_m), 
    .reg_wr(reg_wr_m), 
    .wb_sel(wb_sel_m),
    .mem_addr_sel(mem_addr_sel_m),
    .mem_data_sel(mem_data_sel_m),
    .imm_out(imm_m),
    .out_en(out_en_m)
);

/* =================== MEMORY =================== */

// FIX: Stack Pointer Address Correction for PUSH/CALL
wire [7:0] sp_corrected;
assign sp_corrected = (mem_wr_m) ? (sp + 8'd1) : sp;

MUX4 m4(
    .sel(mem_addr_sel_m), 
    .sp(sp_corrected),     
    .ea(imm_m), 
    .rdata1(A_e), 
    .alu_res(alu_m), 
    .addr(mem_addr)
);

MUX6 m6(
    .sel(mem_data_sel_m), 
    .rdata2(B_m), 
    .alu_res(alu_m), 
    .pc1(8'h00), 
    .flags({4'b0,V,C,N,Z}), 
    .write_data(mem_wdata)
);

DataMemory dmem(
    .clk(clk), 
    .address(mem_addr), 
    .write_data(mem_wdata),
    .rd_en(mem_rd_m), 
    .wr_en(mem_wr_m), 
    .rd_data(rd_data)
);

/* =================== MEM/WB =================== */

MEM_WB_Extended memwb(
    .clk(clk), 
    .reset(reset),
    .imm_in(imm_m),
    .mem_data_in(rd_data), 
    .alu_res_in(alu_m), 
    .wb_addr_in(wb_addr_m), 
    .reg_wr_in(reg_wr_m),
    .wb_sel_in(wb_sel_m),
    .mem_data(memwb_mem), 
    .alu_res(memwb_alu), 
    .wb_addr(memwb_wb_addr), 
    .reg_wr(memwb_reg_wr), 
    .imm(memwb_imm),
    .wb_sel(memwb_wb_sel)
);

/* =================== WRITE BACK =================== */

MUX5 wb_mux(
    .sel(memwb_wb_sel), 
    .alu_result(memwb_alu), 
    .rd_data(memwb_mem), 
    .in_port(IN_PORT), 
    .immediate(memwb_imm), 
    .wdata(wb_data)
);

/* =================== OUTPUT PORT =================== */

OutputPort out_port(
    .clk(clk),
    .reset(reset),
    .out_en(out_en_m),
    .data_in(alu_m),
    .OUT_PORT(OUT_PORT)
);

endmodule