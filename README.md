8-Bit Pipelined RISC Processor

> A fully functional 8-bit pipelined processor designed and implemented in Verilog, featuring a custom 32-instruction RISC-like ISA, FSM-based control unit, and data forwarding.

---

## Overview

This project implements a simple 8-bit pipelined processor using Harvard memory architecture in Verilog. The processor conforms to a custom RISC-like ISA with 32 instructions, a 256-byte byte-addressable memory space, and a pipelined datapath with data forwarding support.

---

## Features

- 32-instruction RISC-like ISA across 3 instruction formats (A, B, L)
- Harvard memory architecture
- Pipelined datapath with FSM-based control unit
- Data forwarding to resolve pipeline hazards
- 4 general-purpose 8-bit registers (R0–R3), with R3 as stack pointer
- Condition code register with Z, N, C, and V flags
- Stack-based PUSH, POP, CALL, and RET operations
- Input/output ports and reset signal support

---

## Simulation

Simulated and verified using **Questa Sim**. Waveform analysis was used to confirm correct instruction execution across all 32 instructions.
