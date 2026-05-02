module tb_memory();

reg clk;
reg [7:0] sp, ea, rdata1, alu_res;
reg [1:0] addr_sel;
reg [1:0] data_sel;
reg mem_rd, mem_wr;
reg [7:0] rdata2;
reg [7:0] pc1;
reg [7:0] flags;

wire [7:0] mem_addr;
wire [7:0] mem_wdata;
wire [7:0] rd_data;

// MUX4
MUX4 m4(addr_sel, sp, ea, rdata1, alu_res, mem_addr);

// MUX6
MUX6 m6(data_sel, rdata2, alu_res, pc1, flags, mem_wdata);

// Data Memory
DataMemory dm(clk, mem_addr, mem_wdata, mem_rd, mem_wr, rd_data);

always #5 clk = ~clk;

initial begin
    clk = 0;

    // Store 55 at EA=10
    sp = 8'hFF;
    ea = 8'd10;
    rdata1 = 0;
    alu_res = 0;
    rdata2 = 8'd55;

    addr_sel = 2'b01; // EA
    data_sel = 2'b00; // rdata2
    mem_wr = 1; mem_rd = 0;
    #10 mem_wr = 0;

    // Load from EA=10
    mem_rd = 1;
    #10 mem_rd = 0;

    // Push value 77 on stack
    rdata2 = 8'd77;
    sp = 8'd20;
    addr_sel = 2'b00; // SP
    data_sel = 2'b00;
    mem_wr = 1; #10 mem_wr = 0;

    // Pop from stack
    mem_rd = 1; #10 mem_rd = 0;

    $stop;
end

endmodule

