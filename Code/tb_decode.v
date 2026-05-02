module tb_decode();

reg clk, reset;
wire [3:0] opcode;
wire [1:0] ra, rb;
wire [7:0] immediate;

// Writeback control (simulate CU)
reg rf_we;
reg [1:0] rf_waddr;
reg [7:0] rf_wdata;

// Instantiate FETCH
FETCH fetch (
    .clk(clk), .reset(reset), .pc_en(1'b1), .pc_src_sel(2'b00),
    .intr(1'b0), .reset_vector(8'h00),
    .rdata2(8'h00), .rd_data(8'h00),
    .opcode(opcode), .ra(ra), .rb(rb), .immediate(immediate)
);

// Pipeline Reg
wire [3:0] op_d;
wire [1:0] ra_d, rb_d;
wire [7:0] imm_d;

IF_ID ifid(clk, reset, 1'b0, opcode, ra, rb, immediate,
           op_d, ra_d, rb_d, imm_d);

// Register File
RegisterFile rf (
    .clk(clk), .reset(reset),
    .we(rf_we),
    .waddr(rf_waddr),
    .wdata(rf_wdata),
    .raddr1(ra_d),
    .raddr2(rb_d),
    .rdata1(), .rdata2(), .sp_value()
);

always #5 clk = ~clk;

initial begin
    clk = 0; reset = 1;
    rf_we = 0;

    #10 reset = 0;

    // simulate Control Unit for LDM
    // LDM ra=0, rb=1, immediate = 5
    #20 rf_we = 1; rf_waddr = 2'd1; rf_wdata = imm_d;
    #10 rf_we = 0;

    #20 rf_we = 1; rf_waddr = 2'd2; rf_wdata = imm_d;
    #10 rf_we = 0;

    #100 $stop;
end

endmodule

