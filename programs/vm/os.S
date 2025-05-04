/*
 * File: os.S
 * Description: Example of how to enable virtual memory and load and run a user program.
 */

#define USER_1_PA         (0x0000000080005000ULL)
#define USER_1_VA         (0x0000000080001000ULL)

#define USER_2_PA         (0x0000000080006000ULL)
#define USER_2_VA         (0x0000000080002000ULL)

#define KERNEL_PA       (0x0000000080000000ULL)
#define PT2_PA          (0x0000000080002000ULL)
#define PT1_PA          (0x0000000080003000ULL)
#define PT0_PA          (0x0000000080004000ULL)

# Page Number Getters
#define PN(PA)          (PA >> 12)
#define PN0(PA)         (PA >> 12 & 0x1ff)
#define PN1(PA)         (PA >> 21 & 0x1ff)
#define PN2(PA)         (PA >> 30 & 0x1ff)

.text
.global _start;

_start:
.align 2
bootloader:

        # Setup machine mode trap handler
        la      t1, m_trap;
        csrw    mtvec, t1;
        
        # Set medeleg 
        li      t4, 0x100;
        csrs    medeleg, t4;

        # Init PT2
        li t2, PT2_PA + 8*PN2(PT1_PA);
        li t3, (PN(PT1_PA) << 10) | 0x1; # pointer to PT1
        sw t3, 0(t2);

        # Init PT1
        li t2, PT1_PA + 8*PN1(PT0_PA);
        li t3, (PN(PT0_PA) << 10) | 0x1; # pointer to PT0
        sw t3, 0(t2);

        # Init PT0
        # Set KERNEL_PA->KERNEL_PA
        li t2, PT0_PA + 8*PN0(KERNEL_PA);
        li t3, (PN(KERNEL_PA) << 10) | 0xef;
        sw t3, 0(t2);
        # Set PT2_PA->PT2_PA
        li t2, PT0_PA + 8*PN0(PT2_PA);
        li t3, (PN(PT2_PA) << 10) | 0xef;
        sw t3, 0(t2);
        # Set PT1_PA->PT1_PA
        li t2, PT0_PA + 8*PN0(PT1_PA);
        li t3, (PN(PT1_PA) << 10) | 0xef;
        sw t3, 0(t2);
        # Set PT0_PA->PT0_PA
        li t2, PT0_PA + 8*PN0(PT0_PA);
        li t3, (PN(PT0_PA) << 10) | 0xef;
        sw t3, 0(t2);


        # cfig PMP
        # entry0: addr 0x0_0000_0000~0x2_ffff_ffff, l=0 a=1 x=1 w=1 r=1
        li   x1, 0x0f;
        csrw pmpcfg0, x1;
        li   x1, 0xc0000000;
        csrw pmpaddr0, x1;

        # Get into supervisor mode
        li t4, (1 << 11) | (1 << 5);
        csrw mstatus, t4;
        la t5, OS;
        csrw mepc, t5;
        mret;

.align 2
m_trap:
        nop;
        ecall;


.align 2
OS:
        # Setup supervisor mode trap handler
        la      t1, s_trap;
        csrw    stvec, t1;

        # Enable virtual memory
        li a0, (8 << 60) | PN(PT2_PA);
        csrw satp, a0;
        sfence.vma; # Refetch the SATP register

        # Set USER_1_VA->USER_1_PA
        li t2, PT0_PA + 8*PN0(USER_1_VA);
        li t3, (PN(USER_1_PA) << 10) | 0xff;
        sw t3, 0(t2);

        # Set USER_2_VA->USER_2_PA
        li t2, PT0_PA + 8*PN0(USER_2_VA);
        li t3, (PN(USER_2_PA) << 10) | 0xff;
        sw t3, 0(t2);

        # Enable writing to User PTE in S-Mode
        li t0, (1 << 18);
        csrs sstatus, t0;

        # Load program 1 to user space
        bge x, 2, U2;
        la t0, user_program_1; # Load the the address to start copying into t0
        la t1, user_program_1_end # Load the address to stop copying into t1
        li t3, USER_1_VA; # Load the destination address into t3
        j 1;
U2:
        # Load program 2 to user space
        bge x, 3, exit;
        la t0, user_program_2; # Load the the address to start copying into t0
        la t1, user_program_2_end # Load the address to stop copying into t1
        li t3, USER_2_VA; # Load the destination address into t3
        j 1;
exit:
        # return to machine mode
        ecall;

1:
        lw t4, 0(t0); # Load a word from the user program
        sw t4, 0(t3); # Store the  word to the destination
        addi t0, t0, 4; # Increment the user program address
        addi t3, t3, 4; # Increment the destination address
        blt t0, t1, 1b; # Repeat until the end of the user program is reached

        # Disable writing to User PTE in S-Mode
        li t0, (1 << 18);
        csrc sstatus, t0;

        # Get into user mode
        li      t5, USER_VA;
        csrw    sepc, t5;
        sret;

.align 2
s_trap:
        la t0, x;
        lw t1, 0(t0);
        addi t1, t1, 1;
        sw t1, 0(t0);
        j OS;

        .data
x: .byte 1        # x = 1

.align 2
user_program_1:
        # store 154 at USER_1_VA+0xf00
        li      t0, 0x154b;
        li      t1, USER_1_VA+0xf00;
        sw      t0, 0(t1);
        # load 154 to t2
        lw      t2, 0(t1);
        # exit
        li      a0, 0;
        li      a7, 93;
        ecall;
user_program_1_end:

.align 2
user_program_2:
        # store 154 at USER_2_VA+0xf00
        li      t0, 0x154b;
        li      t1, USER_2_VA+0xf00;
        sw      t0, 0(t1);
        # load 154 to t2
        lw      t2, 0(t1);
        # exit
        li      a0, 0;
        li      a7, 93;
        ecall;
user_program_2_end:

        .section ".tohost","aw",@progbits
        .globl tohost
        .globl fromhost

        .align 6
tohost: .dword 0
        .align 6
fromhost: .dword 0
