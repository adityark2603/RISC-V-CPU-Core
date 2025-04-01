# RISC-V-CPU-Core
Built a RISC-V CPU Core using Transaction-Level Verilog 



RISC-V CPU Block Diagram:
![CPU](https://github.com/user-attachments/assets/541a09ac-781a-4ee2-a012-331334622573)

1. PC Logic: This logic is responsible for the program counter (PC). The PC identifies the instruction our CPU will execute next. Most instructions execute sequentially, meaning the default behavior of the PC is to increment to the following instruction each clock cycle. Branch and jump instructions, however, are non-sequential. They specify a target instruction to execute next, and the PC logic must update the PC accordingly.

2. Fetch: The instruction memory (IMem) holds the instructions to execute. To read the IMem, or “fetch”, we simply pull out the instruction pointed to by the PC.

3. Decode Logic: Now that we have an instruction to execute, we must interpret, or decode, it. We must break it into fields based on its type. These fields would tell us which registers to read, which operation to perform, etc.

4. Register File Read: The register file is a small local storage of values the program is actively working with. We decoded the instruction to determine which registers we need to operate on. Now, we need to read those registers from the register file.

5. Arithmetic Logic Unit (ALU): Now that we have the register values, it’s time to operate on them. This is the job of the ALU. It will add, subtract, multiply, shift, etc, based on the operation specified in the instruction.

6. Register File Write: Now the result value from the ALU can be written back to the destination register specified in the instruction.

7. DMem: Our test program executes entirely out of the register file and does not require a data memory (DMem). But no CPU is complete without one. The DMem is written to by store instructions and read from by load instructions.

