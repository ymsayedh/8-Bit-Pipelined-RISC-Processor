module RegisterFile (
    input  wire clk,
    input  wire reset,

    // Writeback
    input  wire we,
    input  wire [1:0] waddr,
    input  wire [7:0] wdata,

    // Stack Pointer Control (NEW)
    input  wire sp_inc, // For POP / RET
    input  wire sp_dec, // For PUSH / CALL

    // Read ports
    input  wire [1:0] raddr1,
    input  wire [1:0] raddr2,

    output wire [7:0] rdata1,
    output wire [7:0] rdata2,

    output wire [7:0] sp_value
);

    reg [7:0] regs [0:3]; // R0..R3

    assign rdata1 = regs[raddr1];
    assign rdata2 = regs[raddr2];
    assign sp_value = regs[2'b11]; // R3 is SP

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            regs[0] <= 0;
            regs[1] <= 0;
            regs[2] <= 0;
            regs[3] <= 8'hFF; // SP init = 255
        end else begin
            // Normal Write
            if (we) begin
                regs[waddr] <= wdata;
            end

            // Stack Pointer Update logic (Independent of 'we')
            if (sp_inc) begin
                regs[3] <= regs[3] + 8'd1;
            end
            else if (sp_dec) begin
                regs[3] <= regs[3] - 8'd1;
            end
        end
    end

endmodule