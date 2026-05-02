module tb_minimal();

reg clk, reset;
reg [7:0] IN_PORT;
wire [7:0] OUT_PORT;

ProcessorTop DUT(clk, reset, IN_PORT, OUT_PORT);

always #5 clk = ~clk;

// Detailed cycle-by-cycle monitoring
integer cycle;
always @(posedge clk) begin
    if (!reset) begin
        $display("Cycle %0d: PC=%02h R0=%02h R1=%02h R2=%02h R3=%02h OUT=%02h | opcode_d=%h rf_we_cu=%b rf_waddr_cu=%h wb_sel_cu=%h", 
                 cycle, DUT.PC_f, DUT.rf.regs[0], DUT.rf.regs[1], DUT.rf.regs[2], DUT.rf.regs[3], OUT_PORT,
                 DUT.opcode_d, DUT.rf_we_cu, DUT.rf_waddr_cu, DUT.wb_sel_cu);
        cycle = cycle + 1;
    end
end

initial begin
    clk = 0;
    reset = 1;
    IN_PORT = 8'h00;
    cycle = 0;

    #12 reset = 0;
    
    $display("=== Testing Single LDM Instruction ===\n");

    #100;
    
    $display("\n=== Result After 10 Cycles ===");
    $display("Expected: R1 = 0x05");
    $display("Actual:   R1 = 0x%02h", DUT.rf.regs[1]);
    
    if (DUT.rf.regs[1] == 8'h05)
        $display("TEST PASSED!");
    else
        $display("TEST FAILED!");

    $finish;
end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_minimal);
end

endmodule