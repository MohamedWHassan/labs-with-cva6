
# Branch Prediction

In this lab, you will need to modify the existing [branch predictor](https://github.com/openhwgroup/cva6/blob/b44a696bbead23dafb068037eff00a90689d4faf/core/frontend/bht.sv). See the [Your Own Repository Guide](../guides/your-own-repo.md) for our recommended way to organize and collaborate on labs.

## Pre-Lab Questions

1. What is the purpose of a branch predictor? Why does a single-cycle core not need branch prediction? \
   The branch predictor tries to guess which way a branch will go. A single-cycle core doesn't need branch prediction because the branch decision is known within a single cycle and there
   is no pipeline to fill upcoming instructions.
3. Define and compare and contrast the following:
    * Static branch prediction vs. Dynamic branch prediction
      Static branch prediction: The branch would always be assumed to be taken until it is evaluated. \
      Dynamic branch prediction: The branch decision is determined according to the dynamic history of core execution.
    * One-level branch prediction vs. Two-level predictor \
      One-level branch prediction: Uses one bit only in the branch buffer to indicate if the last branch prediction was taken or not. \
      Two-level branch prediction: Uses two bits to indicate if the branch has been taken before atleast two times or not. It takes two 
    * Local branch prediction vs. Global branch prediction \
      Local branch predicts based on the current branch. \
      Global branch predicts based on previous related branches.
4. Define BHT, BTB and RAS. What are they used for? \
   BHT: Branch History Table, memory array indexed by low order bits in the address and it indicates if the branch was previously taken or not. \
   BTB: Branch Target Buffer, Stores the target for the branches and provides prediction results. \
   RAS: Return Address Stack, stores the PC of instructions following JAL to be returned to after a "ret" is issued.
6. Look at [frontend.sv](https://github.com/openhwgroup/cva6/blob/b44a696bbead23dafb068037eff00a90689d4faf/core/frontend/frontend.sv). What are the 4 types of instructions that the branch predictor handles, and how are they handled? \
   The four types of instructions are branch, return, jump, and jump and link. \
   Branch: If it is a branch instruction, and dynamic target branch prediction from the BHT is valid, then we use the BHT predicted address as the next PC. \
   Else, the prediction is statically defined and it is taken if we have a negative   relative jump offset while if it positive the branch is not taken.

   Return: The predicted addres comes from the RAS unit as this is a return from a jump instruction.
   
   Jump: This jumps to a register and no prediction is needed as the address is already in the instruction??? maybe?
   
   Jal: BTB will generate the predicted address if it returns a valid address. Otherwise, it is not considered as a control flow instruction and it will generate a mispredict.
   
8. How is a branch resolution handled?
   If it is a branch instruction, and dynamic target branch prediction from the BHT is valid, then we use the BHT     predicted address as the next PC. Else, the prediction is statically defined and it is taken if we have a negative         relative jump offset while if it positive the branch is not taken.

10. What kind of dynamic branch predictor does CVA6 use?
    A two bit branch predictor.
12. Provide a GitHub permalink to where in `ariane_pkg` the branch predictor structs are defined.
    https://github.com/openhwgroup/cva6/blob/b44a696bbead23dafb068037eff00a90689d4faf/core/include/ariane_pkg.sv#L326
    
14. When can more than 1 instruction be fetched per cycle?
When compressed extention is enabled.

## Part 1 - CVA6 Predictor

Add functionality to [frontend.sv](https://github.com/openhwgroup/cva6/blob/b44a696bbead23dafb068037eff00a90689d4faf/core/frontend/frontend.sv) that records the branch predictor hit-rate.

To do this, you can create an `always_ff @(posedge clk)` block that counts how many times a branch has been resolved, and how many of those resolutions were mispredicts. ([Branch resolve net](https://github.com/openhwgroup/cva6/blob/b44a696bbead23dafb068037eff00a90689d4faf/core/frontend/frontend.sv#L30); [branch resolve type](https://github.com/openhwgroup/cva6/blob/b44a696bbead23dafb068037eff00a90689d4faf/core/include/ariane_pkg.sv#L338-L345).) The hit-rate can be calculated with 1-num_mispredicts/num_valid_resolutions. You can then record the hit-rate to a file on every clock cycle; this way, you are certain to get the final hit-rate when the simulation terminates.

### Part 1 Questions

1. Highlight your changes to `"frontend.sv"` that records the hit-rate.
```systemverilog
//TODO: Part 1 Question CVA6 branch Predictor performance
    //TODO: Count how many resolutions were mispredicts HITRATE = 1-(num_mispredicts/num_valid_resolutions)
    real valid_counter = 0;
    real mispredict_counter = 0;
    real div = 0;
    integer f;
    initial begin
        f = $fopen("bp.txt","w");
    end
    always_ff @(posedge clk_i) begin
      if(resolved_branch_i.valid) begin
        valid_counter <= valid_counter + 1;
        if(resolved_branch_i.is_mispredict)
          mispredict_counter <= mispredict_counter + 1;
          div = 1 - (mispredict_counter / valid_counter);
      end
      $fwrite(f, "%f\n", div);
    end
    //TODO: End modifications 
```
2. What are the final hit-rate percentages of each of the [bp benchmarks](https://github.com/sifferman/labs-with-cva6/tree/main/programs/bp)? \
  div: 69.4% \
  loop: 89.3% \
  spagetti: 96%
3. Compare the performance of the [bp benchmarks](https://github.com/sifferman/labs-with-cva6/tree/main/programs/bp) after choosing 3 new values for [`NR_ENTRIES`](https://github.com/openhwgroup/cva6/blob/b44a696bbead23dafb068037eff00a90689d4faf/core/frontend/frontend.sv#L419). Display the 4 hit-rates in a table and explain how and why each program changes its hit-rate as BHT size changes. *Note: When changing `NR_ENTRIES`, be sure to change `NR_ENTRIES` in the `bht` instantiation in `"frontend.sv"`, not the `bht` declaration in `"bht.sv"`. Also your `NR_ENTRIES` values should be on the order of 16 to have interesting results. \
```answer
For the `loop.s`, the number of branches are 3 so they fit into the the 16 interies BHT.
For the `spagetti.s`, the number of branches is more than 30 so increasing the number of entries plays a role in increasing the accuracy.
For the `div.s`, 
```
| *Name*       | *16* | *32* | *48* | *64* |*relation*| 
|:-----------|---:|:--:|:--:|:--:|:--:|
| dive       |74% |69% |63% |69% |decreases|
| loop       |89% |89% |89% |89% |constant|
| spagetti   |75% |88% |82% |95% |increasing|
### Example of How to Write to a File in Verilog/SystemVerilog

```systemverilog
integer f;
integer counter;
initial begin
    f = $fopen("bp.txt","w");
end
always @(posedge clk) begin
    $fwrite(f, "%f\n", $itor(counter));
end
```

## Part 2 - Global Predictor

In this part, you will modify the [bht.sv](https://github.com/openhwgroup/cva6/blob/b44a696bbead23dafb068037eff00a90689d4faf/core/frontend/bht.sv) and turn it into a [global two-level adaptive branch predictor](https://en.wikipedia.org/wiki/Branch_predictor#Global_branch_prediction). First, read through the [Global Branch Predictor Specifications](#global-branch-predictor-specifications) section.

A few notes on your implementation:

* Choose your own values for `n` and `m`
* You can use whatever algorithm you want to calculate the BHT index
    * You can use Gshare or Gselect
    * You may also choose to use [XORShift](https://en.wikipedia.org/wiki/Xorshift), a simple random-number-generation algorithm, to create a hash that will index into your BHT
* Be sure that your BHT size is decided by the parameter `NR_ENTRIES`
* Be sure to remove all unused lines of code leftover from the initial implementation
* Be sure to comment your design clearly

### Part 2 Questions

1. Share your modified `"bht.sv"` that implements the global two-level adaptive branch predictor.
```systemverilog
// branch history table - 2 bit saturation counter
module bht #(
    parameter int unsigned NR_ENTRIES = 1024
)(
    input  logic                        clk_i,
    input  logic                        rst_ni,
    input  logic                        flush_i,
    input  logic                        debug_mode_i,
    input  logic [riscv::VLEN-1:0]      vpc_i,
    input  ariane_pkg::bht_update_t     bht_update_i,
    // we potentially need INSTR_PER_FETCH predictions/cycle
    output ariane_pkg::bht_prediction_t [ariane_pkg::INSTR_PER_FETCH-1:0] bht_prediction_o
);
    // the last bit is always zero, we don't need it for indexing
    localparam OFFSET = ariane_pkg::RVC == 1'b1 ? 1 : 2;
    // re-shape the branch history table
    localparam NR_ROWS = NR_ENTRIES / ariane_pkg::INSTR_PER_FETCH;
    // number of bits needed to index the row
    localparam ROW_ADDR_BITS = $clog2(ariane_pkg::INSTR_PER_FETCH);
    localparam ROW_INDEX_BITS = ariane_pkg::RVC == 1'b1 ? $clog2(ariane_pkg::INSTR_PER_FETCH) : 1;   // 1    1
    // number of bits we should use for prediction
    localparam PREDICTION_BITS = $clog2(NR_ROWS) + OFFSET + ROW_ADDR_BITS;
    // we are not interested in all bits of the address
    unread i_unread (.d_i(|vpc_i));
    // local param
    localparam n = 30;

    struct packed {
        logic       valid;
        logic [1:0] saturation_counter;
    } bht_d[NR_ROWS-1:0][ariane_pkg::INSTR_PER_FETCH-1:0], bht_q[NR_ROWS-1:0][ariane_pkg::INSTR_PER_FETCH-1:0];

    logic [$clog2(NR_ROWS)-1:0]  index, update_pc, gshare_update_pc, gshare_index;
    logic [ROW_INDEX_BITS-1:0]    update_row_index;
    logic [1:0]                  saturation_counter;
    logic [n-1:0] ghr; // global history record that records the last n branches
    always_ff@(posedge clk_i or negedge rst_ni) begin
        if(!rst_ni) begin
            ghr <= 0;
        end
        else begin
            if(bht_update_i.valid)
                ghr <= {bht_update_i.taken, ghr[n-1:1]};
        end
    end

    assign index     = vpc_i[PREDICTION_BITS - 1:ROW_ADDR_BITS + OFFSET];
    assign gshare_index = index ^ ghr;
    assign update_pc = bht_update_i.pc[PREDICTION_BITS - 1:ROW_ADDR_BITS + OFFSET]; // XOR update PC and GHR
    assign gshare_update_pc = update_pc ^ ghr;

    if (ariane_pkg::RVC) begin : gen_update_row_index
      assign update_row_index = bht_update_i.pc[ROW_ADDR_BITS + OFFSET - 1:OFFSET];
    end else begin
      assign update_row_index = '0;
    end

    // prediction assignment
    for (genvar i = 0; i < ariane_pkg::INSTR_PER_FETCH; i++) begin : gen_bht_output
        assign bht_prediction_o[i].valid = bht_q[gshare_index][i].valid;
        assign bht_prediction_o[i].taken = bht_q[gshare_index][i].saturation_counter[1] == 1'b1;
    end

    always_comb begin : update_bht
        bht_d = bht_q;
        saturation_counter = bht_q[gshare_update_pc][update_row_index].saturation_counter;

        if (bht_update_i.valid && !debug_mode_i) begin
            bht_d[gshare_update_pc][update_row_index].valid = 1'b1;

            if (saturation_counter == 2'b11) begin
                // we can safely decrease it
                if (!bht_update_i.taken)
                    bht_d[gshare_update_pc][update_row_index].saturation_counter = saturation_counter - 1;
            // then check if it saturated in the negative regime e.g.: branch not taken
            end else if (saturation_counter == 2'b00) begin
                // we can safely increase it
                if (bht_update_i.taken)
                    bht_d[gshare_update_pc][update_row_index].saturation_counter = saturation_counter + 1;
            end else begin // otherwise we are not in any boundaries and can decrease or increase it
                if (bht_update_i.taken)
                    bht_d[gshare_update_pc][update_row_index].saturation_counter = saturation_counter + 1;
                else
                    bht_d[gshare_update_pc][update_row_index].saturation_counter = saturation_counter - 1;
            end
        end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            for (int unsigned i = 0; i < NR_ROWS; i++) begin
                for (int j = 0; j < ariane_pkg::INSTR_PER_FETCH; j++) begin
                    bht_q[i][j] <= '0;
                end
            end
        end else begin
            // evict all entries
            if (flush_i) begin
                for (int i = 0; i < NR_ROWS; i++) begin
                    for (int j = 0; j < ariane_pkg::INSTR_PER_FETCH; j++) begin
                        bht_q[i][j].valid <=  1'b0;
                        bht_q[i][j].saturation_counter <= 2'b10;
                    end
                end
            end else begin
                bht_q <= bht_d;
            end
        end
    end
endmodule
```
2. What specifications did you decide on for your predictor? What is your BHT index generation algorithm? How wide is your GHR? Which address bits do you use for your address? \
BHT index generation is the Gshare aglorithm. \
GHR is 30 bit wide. \
The same ones originally used. \
3. Briefly explain your reasoning behind the BHT index generation algorithm you chose.
No reason really it looked nice.
4. Compare the performance of the [bp benchmarks](https://github.com/sifferman/labs-with-cva6/tree/main/programs/bp) after choosing 3 new values for [`NR_ENTRIES`](https://github.com/openhwgroup/cva6/blob/b44a696bbead23dafb068037eff00a90689d4faf/core/frontend/frontend.sv#L419). Display the 4 hit-rates in a table and explain how and why each program changes its hit-rate as BHT size changes.

| *Name*       | *16* | *32* | *48* | *64* |*relation*| 
|:-----------|---:|:--:|:--:|:--:|:--:|
| dive       |68% |70% |61% |73% |almost no change|
| loop       |89% |89% |94% |95% |increases|
| spagetti   |71% |62% |69% |77% |increasing|

## Global Branch Predictor Specifications

*This section describes the specifications required to build a global two-level adaptive branch predictor.*

For global branch predictors, a global history record (GHR) must be kept. A GHR keeps a record of the past `n` branches using a FIFO method. To maintain the GHR, when a branch has been resolved, the branch result must be shifted into the GHR while simultaneously dropping the `n`th result.

Similar to a one-level branch predictor, a two-level branch predictor contains a branch history table (BHT) where its entries are (*often*) two-bit saturation counters. However, one-level and two-level predictors differ in how the BHT index is calculated.

For a global two-level adaptive branch predictor, the BHT index is calculated using the current GHR value and using `m` bits from the resolved branch's program counter. The GHR and PC can either be concatenated together (called Gselect) or xor'ed together (called Gshare). Other BHT index calculation algorithms exist but have little effect on the predictor performance.

### 2-Bit Saturation Counter

![2-Bit Saturation Counter](bp/saturation_counter.svg)

### Global Predictor

![Global Predictor](bp/global_predictor.svg)

## Extra Credit

Branches come in many patterns in real code, and it is not uncommon to find that different styles of branch prediction have value in different situations. Extend your predictor to contain a "Tournament" of CVA6's predictor and your global predictor, with a sensible mechanism for updating trust based on successful or failed predictions.

## Code Submission

Submit to the Gradescope Autograder your modified `"bht.sv"` that implements a global two-level adaptive branch predictor. The autograder will verify the hit-rate for several different programs, but your implementation will be verified manually.
