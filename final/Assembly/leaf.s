.data
    a: .word 6
    b: .word 9
    c: .word 14
    d: .word 4
.text
.globl __start

auipc x6, 0
jalr x0, x6, 36

leaf:
    xor x5, x10, x11
    xor x6, x11, x12
    xor x7, x12, x13
    add x28, x5, x6
    sub x29, x28, x7
    addi x10, x29, 0
    jalr x0, 0(x1)
    
__start:
    la t0, a
    lw x10, 0(t0)
    la t0, b
    lw x11, 0(t0)
    la t0, c
    lw x12, 0(t0)
    la t0, d
    lw x13, 0(t0)
    jal x1, leaf
    la t0, b
    sw x10, 12(t0)
    li a7, 10
    ecall