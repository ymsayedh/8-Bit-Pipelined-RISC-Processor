module tb_fetch();

reg clk;
reg reset;
reg pc_en;
reg [1:0] pc_src_sel;
reg intr;

wire [3:0] opcode;
wire [1:0] ra, rb;
wire [7:0] immediate;

FETCH dut (
    .clk(clk),
    .reset(reset),
    .pc_en(pc_en),
    .pc_src_sel(pc_src_sel),
    .intr(intr),
    .reset_vector(8'h00),
    .rdata2(8'h00),
    .rd_data(8'h00),
    .opcode(opcode),
    .ra(ra),
    .rb(rb),
    .immediate(immediate)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    reset = 1;
    pc_en = 1;
    pc_src_sel = 2'b00; // PC+1
    intr = 0;

    #10 reset = 0;

    // Let PC run normally
    #100;

    // Test PC+2 (2-byte instr)
    pc_src_sel = 2'b01;
    #20;

    // Test JMP source (rdata2)
    pc_src_sel = 2'b10;
    #20;

    // Test RET source (rd_data)
    pc_src_sel = 2'b11;
    #20;

    $stop;
end

endmodule
