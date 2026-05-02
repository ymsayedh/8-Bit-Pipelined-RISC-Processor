# 1. Create the library and compile ALL Verilog files
vlib work
vlog *.v

# 2. Simulate the NEW Top-Level Testbench
vsim -voptargs=+acc work.tb_ProcessorTop

# 3. Add Waveforms (Organized for Debugging)

add wave -divider "Clock & Reset"
add wave -color "white" /tb_ProcessorTop/clk
add wave -color "white" /tb_ProcessorTop/reset

add wave -divider "PC & Instruction"
add wave -radix unsigned /tb_ProcessorTop/DUT/fetch/PC
add wave -radix hexadecimal /tb_ProcessorTop/DUT/opcode_d
add wave -radix hexadecimal /tb_ProcessorTop/DUT/imm_d

add wave -divider "Register File"
# Shows R0, R1, R2, R3 (SP)
add wave -radix hexadecimal /tb_ProcessorTop/DUT/rf/regs

add wave -divider "Flags"
add wave /tb_ProcessorTop/DUT/Z
add wave /tb_ProcessorTop/DUT/N
add wave /tb_ProcessorTop/DUT/V
add wave /tb_ProcessorTop/DUT/C

add wave -divider "Memory Access"
add wave -radix hexadecimal /tb_ProcessorTop/DUT/mem_addr
add wave -radix hexadecimal /tb_ProcessorTop/DUT/mem_wdata
add wave /tb_ProcessorTop/DUT/mem_wr_m
add wave -radix hexadecimal /tb_ProcessorTop/DUT/rd_data

add wave -divider "Output Port"
add wave -radix hexadecimal /tb_ProcessorTop/OUT_PORT

# 4. Run the simulation
# Run enough time for all instructions to complete
run 300ns

# 5. Zoom to fit
wave zoom full