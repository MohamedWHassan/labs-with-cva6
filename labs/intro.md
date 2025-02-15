
# Introduction to CVA6

This lab will help you become acquainted with the CVA6 core. First, you will need to read through and follow along with the [Getting Started Guide](../guides/getting-started.md). If you are having difficulties with the tool setup, please first complete the questions that do not require any setup.

## GitHub Questions

We are assuming that you have some familiarity with Git and GitHub already. If you do not, I recommend first watching this [Git and GitHub introductory video](https://www.youtube.com/watch?v=e-9qScNVs1o&t=251s).

Next, refer to this guide as needed: [Creating a permanent link to a code snippet](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/creating-a-permanent-link-to-a-code-snippet).

1. What is a Git commit? What is the hash of the commit that first added [this file](https://github.com/sifferman/labs-with-cva6/blob/main/labs/intro.md) to this repository?
2. Using [`"./labs/intro/git-example.txt"`](https://github.com/sifferman/labs-with-cva6/blob/main/labs/intro/git-example.txt), provide a link (URL) to the line that describes who wrote that file.
3. Using that same file, open its initial commit and create a permalink to the line that describes who wrote that file.
4. Why should you always use permalinks as opposed to regular links when sharing lines of code via GitHub?
5. What is a Git submodule, and what are they used for? What is the hash of the cva6 submodule that this repository uses?

## SystemVerilog Questions

1. Provide a link to the IEEE 1800-2017 SystemVerilog standard. (You will need the UCSB network to access <https://ieeexplore.ieee.org/Xplore/home.jsp>)
   https://ieeexplore.ieee.org/document/8299595
3. In the keyword `always_comb`, what does "comb" refer to? What is its Verilog equivalent? Provide a GitHub permalink to an instance of `always_comb` in CVA6.
   combinational
5. In the keyword `always_ff`, what does "ff" refer to? What is its Verilog equivalent? Provide a GitHub permalink to an instance of `always_ff` in CVA6.
   flipflop
6. What is a SystemVerilog package, and how do you reference its contents in another file? Provide a GitHub link to `ariane_pkg.sv` and a permalink to an instance where `ariane_pkg` is imported and used in another file.
   SystemVerilog packages store data, methods, and parameters across modules. The contents can be referenced using the `include compiler directive.
   ariane_pkg.sv
   https://github.com/openhwgroup/cva6/blob/b44a696bbead23dafb068037eff00a90689d4faf/core/include/ariane_pkg.sv#L1
   instance where ariane_pkg is imported
   https://github.com/openhwgroup/cva6/blob/b44a696bbead23dafb068037eff00a90689d4faf/core/ariane.sv#L16C15-L16C35
   
7. What is a struct, and how do you access struct members? Provide a GitHub link to a struct definition in CVA6 and a permalink to where a member of that struct is used.
   A struct is a user-defined data type that can include multiple data types.
   The struct is ariane_cfg_t
   https://github.com/openhwgroup/cva6/blob/b44a696bbead23dafb068037eff00a90689d4faf/core/include/ariane_pkg.sv#L56
   and members are used here
   https://github.com/openhwgroup/cva6/blob/b44a696bbead23dafb068037eff00a90689d4faf/core/include/ariane_pkg.sv#L83
   
8. What are block names? Provide a GitHub permalink to an instance of a block name in CVA6.
   block names are the module instances in SystemVerilog.
   https://github.com/openhwgroup/cva6/blob/b44a696bbead23dafb068037eff00a90689d4faf/core/ariane.sv#L83C31-L83C50
10. What is DPI and what is it used for? Provide a GitHub permalink to a Verilog file that calls a DPI function, and provide a GitHub permalink to where that function is implemented.
  DPI stands for Direct Programming Interface, which provides the interface between SystemVerilog and foreign languages. import "DPI-C" function void read_elf(input string filename);
  https://github.com/openhwgroup/cva6/blob/7b759a8b712b74e92a1f3232515eb3214bd1a266/corev_apu/tb/ariane_gate_tb.sv#L27
## RISC-V Questions

1. Provide a link to the latest RISC-V ISA Manual.
   https://drive.google.com/file/d/1uviu1nH-tScFfgrovvFCrj7Omv8tFtkp/view
  
3. What are the 6 instruction formats of RISC-V? Give a one-to-three word description of each.
   R-Type : Register based ALU operations
   I-Type : load, jump, imm alu operations
   S-Type : Store from regiter to data memory 
   B-Type : Branch instruction
   U-Type : PC related instructions (JAL) jumb and link
   J-Type : JAL????? removed in version 2.0 of the specification
5. What is a compressed instruction and what are they used for?
   Compressed instructions are 16 bit instructions which reduce static and dynamic code size.

## CVA6 Questions 

1. Attach the block diagram of CVA6 provided in the [core's documentation](https://docs.openhwgroup.org/projects/cva6-user-manual/01_cva6_user/).
   ![image](https://github.com/user-attachments/assets/7d98cb2a-8524-45e4-93e4-fe66d106dc7b)

3. Skim the [CVA6 user manual](https://docs.openhwgroup.org/projects/cva6-user-manual/01_cva6_user/) and give a one sentence summary for each of the 6 pipeline stages.
   The six pipeline stages are PC gen, Fetch, Decode, Issue, Execute, and Commit.
   PC gen: Responsible for generating the next program counter. It includes Branch Target Buffer (BTB), Branch History Table (BHT), and Return Address Stack (RAS).
   Fetch: Request data to CACHE module, realigns the data to store them in instruction queue and transmits instructions to DECODE module. It fetchs up to 4 instructions per cycle
   while the DECODE stage decodes 2 instructions per cycle. 
   Decode: Decodes the RISC-V instructions coming from FRONTEND module and send them to the Issue stage.
   Issue: 1- Issues instructions in order to the execute stage after instruction requirements are met.
          2- Gets the results out of order from the execute stage and reorders them.
          3- send completed instructions to COMMIT stage in order where the archiectural state is modified.
   Execute: A logical stage which encapsulates the following functionalities (ALU, Branch Unit, CSR buffer, Mult, Load, Store, and CVXIF)
   Commit: The architectural state is updated: writing CSR registers, commiting stores and writing back data to register file. It also handles exceptions.
5. Which stages are in the "frontend", and which are in the "backend"?
   (PC gen and getch) are frontend, (decode, issue, execute, and commit) are backend.
7. Expand the following acronyms: RISC-V, CVA6, IF, ID, EX, I\$, D\$, FIFO, TLB, ITLB, CSR, BHT, RAS, BTB, MMU, EPC, MTVEC, LSU, PTW, DTLB, ALU, FPU, OoO, WB, AXI, APU, DPI.
   RISC-V: Reduced Instruction Set Computer five
   CVA6: Core-V Application class processor with a 6 stage pipeline
   IF: Instruction Fetch
   ID: Instruction Decode
   I\$: Instruction Cache
   D\$: Data Cache
   FIFO: First In First Out
   TLB: Translation Lookaside Buffer
   ITLB: Instruction Table Lookaside Buffer
   CSR: Control and Status Register
   BHT: Branch History Table
   RAS: Return Address Stack
   BTB: Branch Targer Buffer
   MMU: Memory Management Unit
   EPC: Exception Program Counter
   MTVEC: Machine Trap Vector Base-Address
   LSU: Load Store Unit
   PTW: Page Table Walker
   DTLB: Data Table Lookaside Buffer
   ALU: Arithmetic Logic Unit
   FPU: Floating Point Unit
   OoO: Out of Order
   WB: Write Back
   AXI: Advanced eXtensible Interface
   APU: Application Processing Unit
   DPI: Direct Programming Interface
9. What is the difference between the `"./cva6/corev_apu"` and `"./cva6/core"` directories?
    ./cva6/core includes source code for the CVA6 core only while the ./cva6/corev_apu includes source code for the CVA6 APU only exclusive of the CVA6 core.
11. What is AXI and what is it primarily used for in CVA6?
    AXI is used as a memory interface within the CVA6.

## ELF Questions

Note that you can view the instructions and PCs of an ELF file with the following command: `riscv64-unknown-elf-objdump -d <PATH TO PROGRAM>.elf`

1. What is an ELF file and where are they used? (Not specific to CVA6)
   ELF file is an Executable and Linkable Format file. They are used in the last stage of software flow where they get offloaded to the instruction memory.
3. What is the difference between segments and sections?
   sections contain data for linking and relocation, while segments contain information for runtime execution.
5. Compile [`"./programs/examples/asm.S"`](https://github.com/sifferman/labs-with-cva6/blob/main/programs/examples/asm.S), and (using your favorite hex viewer) give the offset into the ELF file at which the `add` instruction is located. Please also provide a screenshot.
   The add instruction is located on offset 1000.
7. Write a `.S` file that contains instructions covering all 6 of the instruction formats, a branch taken condition, and a compressed instruction. Compile it to an ELF file and find all the PCs for each of the 8 occurences. Provide the `.S` file and the list of PCs.
    80000000:	7e600293          	li	t0,2022
    80000004:	7e700313          	li	t1,2023
    80000008:	006283b3          	add	t2,t0,t1
    8000000c:	00032e03          	lw	t3,0(t1)
    80000010:	01c32023          	sw	t3,0(t1)
    80000014:	00629263          	bne	t0,t1,80000018 <_start+0x18>
    80000018:	4315                li	t1,5
    8000001a:	4501                li	a0,0
    8000001c:	05d00893          	li	a7,93

## Simulation Questions I have problems with simulation !!!!!!!!!!!

Refer to the [Getting Started Guide](../guides/getting-started.md) if you need help setting up the required tools for simulation.

All CVA6 net hierarchical paths should start with `TOP.ariane_testharness.i_ariane.i_cva6.`. Each module/struct should be separated with `.` until you reach the delcaration of the net. To see a net hierarchical path in GTKWave, you can right-click an added signal and click "Alias Highlighted Signal".

When providing screenshots of waveforms, please include all signals you decide are relevant to demonstrate the event. Improper justification will result in a lower score.

1. Give the net hierarchical path and GitHub permalink of the PC in the instruction decode stage.
2. Give the net hierarchical path and GitHub permalink of the ALU output.
3. Give the net hierarchical path and GitHub permalink of the register file write enable in the commit stage.
4. Simulate [`"./programs/examples/asm.S"`](https://github.com/sifferman/labs-with-cva6/blob/main/programs/examples/asm.S), and provide a waveform screenshot of the `add` instruction occurring in the ALU. Provide justification.
5. Simulate the `.S` file you wrote, and provide a waveform screenshot at: a taken branch, a store to memory, a register file write, and a decode of a compressed instruction. Provide justification.
