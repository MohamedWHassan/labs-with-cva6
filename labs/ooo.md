
# Out-of-Order

In this lab, you will be asked several questions to verify your understanding of Out-of-Order.

## Prelab

Read through the [CVA6 Execute Stage Documentation](https://docs.openhwgroup.org/projects/cva6-user-manual/03_cva6_design/ex_stage.html) and the [CVA6 Issue Stage Documentation](https://docs.openhwgroup.org/projects/cva6-user-manual/03_cva6_design/issue_stage.html), and use them to answer the following questions.

1. What is the purpose of Out-of-Order? \
   Out of Order means that instructions are dispatched and executed out of the initial program order, which increases the performance by executing instructions with ready operands while others are waiting
   for their operands to be ready.
3. Give a brief explanation of Scoreboarding and Tomasulo's Algorithm. What are the pros and cons of each? Which OoO strategy does CVA6 use? (Extra: [Tomasulo's original paper](https://ieeexplore.ieee.org/document/5392028)) \
   Scoreboarding is a structure that allows processors to execute code out-of-order through a series of steps. \
   The instruction is issued to the functional unit when operands are ready. Its operands are ready for reading when there are no RAW conflicts and the instruction is issued only when \
   there is no WAW conlfict which means that earlier instruction wiritng to the same register needs to finish first and the instruction is stalled untill then. \
   After execution the result is written back to the register file only after the unit is clear of WAR hazards.
   In Tomasulo's algorithm, there are reservation stations for each functional unit which hold information needed to execute a single instruction such as operation and operands. \
   reservation stations and general purpose registers hold either the real values or a place holder value that indicates which reservation station will issue the result of the operand. \
   this is known as rgister renaming.
   CVA6 uses scoreboarding as an OoO strategy.
5. CVA6's rename unit will not be enabled for this lab. However, provide pseudocode that would run faster assuming the rename unit was enabled.
6. CVA6 has 7 functional units in [`"ex_stage.sv"`](https://github.com/openhwgroup/cva6/blob/b44a696bbead23dafb068037eff00a90689d4faf/core/ex_stage.sv): ALU, Branch Unit, LSU, Multiplier, CSR Buffer, [FPU](https://github.com/openhwgroup/cvfpu), and [CVXIF](https://github.com/openhwgroup/core-v-xif). For each of the 7 functional units, provide:
   ALU: takes a single cycle, performs addition, subtraction, shifts, comparisons. handles integer computation instructions.
   Branch Unit: takes a single cycle, calculates the target address, and comparison to decide if to take a branch or not, detects branch misprediction and reports corrective actions to PC gen. \
   It handles instructions such as jumps and branches.
   LSU: handles loads and stores from and to external memory. load and store instructions.
   Multiplier: Takes 1 cycle, performs multiplication and division. It handles MUL, DIV operations. \
   CSR buffer: stores the address of the CSR regsiter which the instruction is going to write.
   FPU: Floating point unit. It handles instructions such as floating point operations and floating point loads and stores (load_fp, store_fp, fadd, fsub, fmul, fdiv).
   CVXIF: generic interface.
    1. A brief explanation of its function.
    2. Which instructions it handles.
    3. How many cycles it takes to execute. (You don't have to do this question for the FPU and CVXIF).
8. Briefly describe when the following hazards can occur:
    1. Read after Write (RAW)
       When an instruction that writes to a register is followed by another one that reads from the same register.
    3. Write after Write (WAW)
       When an instruction that writes to a register is followed by another one that writes also to the same regsiter.
    5. Write after Read (WAR)
       When an instruction that reads from a register is followed by another one that writes to the same register. 
9. Using the following diagram of the CVA6 backend, explain the path that an instruction must take through the issue and execute stage. Be sure to include the issue queue, transaction IDs, source operands, the destination register, `rd_clobber`, the scoreboard, and any other important logic in your explanation.

    [![Scoreboard](./ooo/figures/scoreboard.svg)](https://docs.openhwgroup.org/projects/cva6-user-manual/03_cva6_design/issue_stage.html)
The issue stage contains a scoreboard which keeps track of issued instructions, which functional unit they use, and the register they are going to write back to using a signal called rb_clobber. \
It doesn't issue multiple instruction that are going to write to the same distination register. \
It issues instructions only when its operands are ready. \
The scoreboard assigns IDs to each instruction for it to write its result into a unique position in the scoreboard. \

11. After looking through the issue stage and scoreboard RTL, Provide a GitHub permalink to the following in CVA6:
    1. The issue queue instantiation [queue](https://github.com/openhwgroup/cva6/blob/b44a696bbead23dafb068037eff00a90689d4faf/core/scoreboard.sv#L77)
    2. The logic that specifies if a functional unit is ready to execute a new intruction
       FLU : https://github.com/openhwgroup/cva6/blob/b44a696bbead23dafb068037eff00a90689d4faf/core/ex_stage.sv#L231C35-L231C45
    4. The logic that stalls the pipeline due to the execute stage being too full for the next instruction
    5. The logic that determines which instruction(s) will be committed on the next cycle [commit](https://github.com/openhwgroup/cva6/blob/b44a696bbead23dafb068037eff00a90689d4faf/core/scoreboard.sv#L110)

## Lab

Write a program that demonstrates the following situations:

* Out-of-Order Execution
* Read after Write hazard
* Write after Write hazard
* Write after Read hazard
* A branch miss
* The issue queue full

Note:

* A dependency hazard exists only if the instructions are run out-of-order when the dependency is removed. Verify this when writing your RAW, WAW, and WAR hazards.
* To enable out-of-order execution, your program must use a mix of instructions from the 3 functional unit types:
    * No more than 1 fixed latency unit operation (`ALU`, `CTRL_FLOW`, `CSR`, `MULT`) can be run simultaneously.
    * No more than 1 floating point unit operation (`FPU`, `FPU_VEC`) can be run simultaneously.
    * No more than 1 load-store unit operation (`LOAD`, `STORE`) can be run simultaneously.

An example of how to run RISC-V floating point instructions (RVF) is provided here: [`"fpu_example.S"`](https://github.com/sifferman/labs-with-cva6/blob/main/programs/rvf/fpu_example.S)

## Lab Questions

When providing screenshots of waveforms, please include all signals you decide are relevant to demonstrate the event. Improper justification will result in a lower score.

1. Share your program. Be sure each situation is clearly commented.
2. Provide a waveform screenshot and a brief explanation of **how the issue queue is affected** for each of the following situations:
    1. Out-of-Order Execution
    2. Read after Write hazard
    3. Write after Write hazard
    4. Write after Read hazard
    5. A branch miss
    6. The issue queue full
