.data
    n: .word 10
    r: .word 3
.text
.globl __start

auipc x6, 0
jalr x0, x6, 88

perm:
    addi sp, sp, -12
    sw x1, 8(sp)
    sw x10, 4(sp)
    sw x11, 0(sp)
    slti x5, x11, 1
    beq x5, x0, GE
LT:
    addi x10, x0, 1
    lw x11, 0(sp)
    addi sp, sp, 12
    jalr x0, 0(x1)
GE:
    addi x10, x10, -1
    addi x11, x11, -1
    jal x1, perm
    addi x6, x10, 0
    lw x11, 0(sp)
    lw x10, 4(sp)
    lw x1, 8(sp)
    addi sp, sp, 12
    mul x10, x10, x6
    jalr x0, 0(x1)

__start:
    la t0, n
    lw x10, 0(t0)
    la t0, r
    lw x11, 0(t0)
    jal x1, perm
    la t0, n
    sw x10, 8(t0)
    li a7, 10
    ecall