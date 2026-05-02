module tb_execute();

reg [7:0] A, B;
reg [3:0] alu_op;
reg cin;

wire [7:0] result;
wire Z, N, C, V;

ALU dut (A, B, cin, alu_op, result, Z, N, C, V);

initial begin
    // ADD 5 + 3 = 8
    A = 5; B = 3; alu_op = 0; #10;

    // SUB 5 - 3 = 2
    A = 5; B = 3; alu_op = 1; #10;

    // AND 5 & 3 = 1
    alu_op = 2; #10;

    // OR 5 | 3 = 7
    alu_op = 3; #10;

    // NOT 3 = ~3
    alu_op = 4; #10;

    // INC 3 = 4
    alu_op = 5; #10;

    // DEC 3 = 2
    alu_op = 6; #10;

    $stop;
end

endmodule

