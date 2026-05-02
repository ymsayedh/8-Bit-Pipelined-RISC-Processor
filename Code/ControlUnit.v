module ControlUnit (
    input wire [3:0] opcode,
    input wire [1:0] ra,
    input wire [1:0] rb,
    input wire Z, N, C, V,

    // PC control
    output reg pc_en,
    output reg [1:0] pc_src,

    // ALU control
    output reg [3:0] alu_op,
    output reg [1:0] alu_srcA,
    output reg [1:0] alu_srcB,

    // Register File
    output reg rf_we,
    output reg [1:0] rf_waddr,
    output reg [1:0] wb_sel,

    // Memory
    output reg mem_rd,
    output reg mem_wr,
    output reg [1:0] mem_addr_sel,
    output reg [1:0] mem_data_sel,

    // Flags
    output reg ccr_we,
    
    // Output port
    output reg out_en,

    // Stack Pointer Control (NEW)
    output reg sp_inc,
    output reg sp_dec
);

always @(*) begin
    // Defaults
    pc_en = 1;
    pc_src = 2'b00;      // PC+1 (default)
    rf_we = 0;
    mem_rd = 0;
    mem_wr = 0;
    ccr_we = 0;
    out_en = 0;

    alu_op = 4'd0;
    alu_srcA = 2'b00;    // rdata1
    alu_srcB = 2'b00;    // rdata2

    mem_addr_sel = 2'b11;  // alu_res (default)
    mem_data_sel = 2'b00;  // rdata2 (default)

    wb_sel = 2'b00;      // alu_result
    rf_waddr = 2'b00;

    // Default SP controls
    sp_inc = 0;
    sp_dec = 0;

    case(opcode)
        4'd0: begin 
            // NOP
        end

        4'd1: begin // MOV ra, rb
            rf_we = 1;
            rf_waddr = ra;
            alu_op = 4'd0;       // ADD
            alu_srcA = 2'b01;    // rdata2 (rb) - effectively 0 + rb
            alu_srcB = 2'b11;    // 0
            wb_sel = 2'b00;
        end

        4'd2: begin // ADD ra, rb
            rf_we = 1;
            rf_waddr = ra;
            alu_op = 4'd0;       // ADD
            alu_srcA = 2'b00;    // rdata1
            alu_srcB = 2'b00;    // rdata2
            ccr_we = 1;
            wb_sel = 2'b00;
        end

        4'd3: begin // SUB ra, rb
            rf_we = 1;
            rf_waddr = ra;
            alu_op = 4'd1;       // SUB
            alu_srcA = 2'b00;
            alu_srcB = 2'b00;
            ccr_we = 1;
            wb_sel = 2'b00;
        end

        4'd4: begin // AND ra, rb
            rf_we = 1;
            rf_waddr = ra;
            alu_op = 4'd2;       // AND
            alu_srcA = 2'b00;
            alu_srcB = 2'b00;
            ccr_we = 1;
            wb_sel = 2'b00;
        end

        4'd5: begin // OR ra, rb
            rf_we = 1;
            rf_waddr = ra;
            alu_op = 4'd3;       // OR
            alu_srcA = 2'b00;
            alu_srcB = 2'b00;
            ccr_we = 1;
            wb_sel = 2'b00;
        end

        4'd6: begin // RLC/RRC/SETC/CLRC
            case(ra)
                2'd0: begin // RLC rb
                    alu_op = 4'd8;    // ALU RLC
                    rf_we = 1;
                    rf_waddr = rb;    
                    alu_srcB = 2'b00; 
                    wb_sel = 2'b00;   
                    ccr_we = 1;       
                end
                2'd1: begin // RRC rb
                    alu_op = 4'd9;    // ALU RRC
                    rf_we = 1;
                    rf_waddr = rb;
                    alu_srcB = 2'b00;
                    wb_sel = 2'b00;
                    ccr_we = 1;
                end
                2'd2: begin // SETC
                    alu_op = 4'd10;   // ALU SETC
                    ccr_we = 1;       
                    rf_we = 0;        
                end
                2'd3: begin // CLRC
                    alu_op = 4'd11;   // ALU CLRC
                    ccr_we = 1;       
                    rf_we = 0;        
                end
            endcase
        end

        4'd7: begin // PUSH/POP/OUT/IN
            case(ra)
                2'd0: begin // PUSH rb
                    mem_wr = 1;
                    mem_addr_sel = 2'b00; // SP
                    mem_data_sel = 2'b00; // rdata2
                    sp_dec = 1;           // Decrement SP
                end
                2'd1: begin // POP rb
                    mem_rd = 1;
                    rf_we = 1;
                    rf_waddr = rb;
                    mem_addr_sel = 2'b00; // SP
                    wb_sel = 2'b01;       // mem_data
                    sp_inc = 1;           // Increment SP
                end
                2'd2: begin // OUT rb
                    out_en = 1;
                    alu_op = 4'd0;
                    alu_srcA = 2'b01;  // rdata2
                    alu_srcB = 2'b11;  // 0
                end
                2'd3: begin // IN rb
                    rf_we = 1;
                    rf_waddr = rb;
                    wb_sel = 2'b10;    // IN_PORT
                end
            endcase
        end

        4'd8: begin // NOT/NEG/INC/DEC
            rf_we = 1;
            rf_waddr = rb;
            alu_srcA = 2'b01;    // rdata2 (rb value)
            alu_srcB = 2'b00;
            ccr_we = 1;
            wb_sel = 2'b00;
            case(ra)
                2'd0: alu_op = 4'd4; // NOT
                2'd1: alu_op = 4'd7; // NEG
                2'd2: alu_op = 4'd5; // INC
                2'd3: alu_op = 4'd6; // DEC
            endcase
        end

        4'd9: begin // JZ/JN/JC/JV
            case(ra)
                2'd0: if (Z) pc_src = 2'b10; // JZ
                2'd1: if (N) pc_src = 2'b10; // JN
                2'd2: if (C) pc_src = 2'b10; // JC
                2'd3: if (V) pc_src = 2'b10; // JV
            endcase
        end

        4'd10: begin // LOOP ra, rb
            rf_we = 1;
            rf_waddr = ra;
            alu_op = 4'd6;       // DEC
            alu_srcA = 2'b00;    // rdata1 (ra)
            alu_srcB = 2'b00;
            ccr_we = 1;
            wb_sel = 2'b00;
            
            if (!Z) begin
                pc_src = 2'b10; // jump to R[rb]
            end
        end

        4'd11: begin // JMP/CALL/RET/RTI
            case(ra)
                2'd0: pc_src = 2'b10; // JMP - jump to R[rb]
                
                2'd1: begin // CALL
                    // 1. Write PC+1 to Stack
                    mem_wr = 1;
                    mem_addr_sel = 2'b00; // SP
                    
                    // 2. Calculate PC+1 using ALU
                    alu_srcA = 2'b10;     // PC (Input 2 of MUX2)
                    alu_srcB = 2'b10;     // 1  (Input 2 of MUX3)
                    alu_op = 4'd0;        // ADD
                    
                    mem_data_sel = 2'b01; // Write ALU Result (PC+1) to Mem
                    
                    // 3. Jump and Dec SP
                    pc_src = 2'b10;       // Jump to R[rb]
                    sp_dec = 1;           // Decrement SP
                end
                
                2'd2: begin // RET
                    mem_rd = 1;
                    mem_addr_sel = 2'b00; // SP
                    pc_src = 2'b11;       // Load PC from Memory
                    sp_inc = 1;           // Increment SP
                end
                
                2'd3: begin // RTI
                    mem_rd = 1;
                    mem_addr_sel = 2'b00; // SP
                    pc_src = 2'b11;       // Load PC from Memory
                    sp_inc = 1;           // Increment SP
                end
            endcase
        end

        4'd12: begin // LDM/LDD/STD
            case(ra)
                2'd0: begin // LDM rb, imm
                    rf_we = 1;
                    rf_waddr = rb;
                    wb_sel = 2'b11;       // immediate
                end
                
                2'd1: begin // LDD rb, ea
                    mem_rd = 1;
                    rf_we = 1;
                    rf_waddr = rb;
                    wb_sel = 2'b01;       // mem_data
                    mem_addr_sel = 2'b01; // EA
                end
                
                2'd2: begin // STD ea, rb
                    mem_wr = 1;
                    mem_addr_sel = 2'b01; // EA
                    mem_data_sel = 2'b00; // rdata2
                end
            endcase
        end

        4'd13: begin // LDI rb, [ra]
            mem_rd = 1;
            rf_we = 1;
            rf_waddr = rb;
            wb_sel = 2'b01;       // mem_data
            mem_addr_sel = 2'b10; // R[ra]
        end

        4'd14: begin // STI [ra], rb
            mem_wr = 1;
            mem_addr_sel = 2'b10; // R[ra]
            mem_data_sel = 2'b00; // rdata2
        end

        default: begin
            // Keep defaults
        end
    endcase
end

endmodule