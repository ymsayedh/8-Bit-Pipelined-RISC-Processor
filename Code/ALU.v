module ALU (
    input wire [7:0] A,
    input wire [7:0] B,
    input wire carry_in,
    input wire [3:0] alu_op,

    output reg [7:0] result,
    output reg Z, N, C, V
);
    reg [8:0] tmp;
    reg signed [7:0] A_signed, B_signed;

    always @(*) begin
        C = 0;
        V = 0;
        tmp = 9'b0;
        A_signed = A;
        B_signed = B;
        
        case(alu_op)
            4'd0: begin // ADD
                tmp = A + B;
                result = tmp[7:0];
                C = tmp[8];
                V = (A[7] == B[7]) && (result[7] != A[7]);
            end
            
            4'd1: begin // SUB
                tmp = A - B;
                result = tmp[7:0];
                C = tmp[8];
                V = (A[7] != B[7]) && (result[7] != A[7]);
            end
            
            4'd2: result = A & B; // AND
            4'd3: result = A | B; // OR
            4'd4: result = ~B;    // NOT
            
            4'd5: begin // INC
                tmp = B + 1;
                result = tmp[7:0];
                C = tmp[8];
                V = (B == 8'h7F);
            end
            
            4'd6: begin // DEC
                tmp = B - 1;
                result = tmp[7:0];
                C = tmp[8];
                V = (B == 8'h80);
            end
            
            4'd7: begin // NEG
                tmp = (~B) + 1;
                result = tmp[7:0];
                C = tmp[8];
                V = (B == 8'h80);
            end

            // --- NEW OPCODE 6 IMPLEMENTATIONS ---
            4'd8: begin // RLC
                result = {B[6:0], carry_in};
                C = B[7];
            end

            4'd9: begin // RRC
                result = {carry_in, B[7:1]};
                C = B[0];
            end

            4'd10: begin // SETC
                C = 1;
                result = B; // Pass-through
            end

            4'd11: begin // CLRC
                C = 0;
                result = B; // Pass-through
            end
            // ------------------------------------

            default: result = A;
        endcase

        // Z and N flags
        Z = (result == 8'b0);
        N = result[7];
    end
endmodule