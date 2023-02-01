#----------------------------------------------------Do not modify below text----------------------------------------------------
.data
  str1: .string	"This is HW1_1:\nBefore sorting: \n"
  str2: .string	"\nAfter sorting:\n"
  str3: .string	"  "
  num: .dword  10, -2, 4, -7, 6, 9, 3, 1, -5, -8

.globl main

.text
main:
  # Print initiate
  li a7, 4
  la a0, str1
  ecall
  
  # a2 stores the num address, a3 stores the length of  num
  la a2, num
  li a3, 10
  jal prints
  
  la a2, num
  li a3, 10
  jal sort
  
  # Print result
  li a7, 4
  la a0, str2
  ecall

  la a2, num
  li a3, 10
  jal prints
  
  # End the program
  li a7, 10
  ecall
#----------------------------------------------------Do not modify above text----------------------------------------------------
sort:
### Start your code here ###
  addi sp, sp, -40
  sd ra, 32(sp)
  sd x22, 24(sp)
  sd x21, 16(sp)
  sd x20, 8(sp)
  sd x19, 0(sp)
  mv x21, a2
  mv x22, a3
  li x19, 0
for1:
  bge x19, x22, exit1
  addi x20, x19, -1
for2:
  blt x20, x0, exit2
  slli x5, x20, 3
  add x5, x21, x5
  ld x6, 0(x5)
  ld x7, 8(x5)
  ble x6, x7, exit2
  mv a2, x21
  mv a3, x20
  jal ra, swap
  addi x20, x20, -1
  j for2
exit2: 
  addi x19, x19, 1
  j for1
exit1:
  ld x19, 0(sp)
  ld x20, 8(sp)
  ld x21, 16(sp)
  ld x22, 24(sp)
  ld a2, 32(sp)
  addi sp, sp, 40
  jalr x0, 0(a2)
swap:
  slli x6, a3, 3
  add x6, a2, x6
  ld x5, 0(x6)
  ld x7, 8(x6)
  sd x7, 0(x6)
  sd x5, 8(x6)
  jalr x0, 0(ra)
  
  
  jr ra

	

 











#----------------------------------------------------Do not modify below text----------------------------------------------------
# Print function	
prints:
  mv t0, zero # for(i=0)
  # a2 stores the num address, a3 stores the length of  num
  mv t1, a2
  mv t2, a3
printloop:
  bge t0, t2, printexit # if ( i>=length of num ) jump to printexit 
  slli t4, t0, 3
  add t5, t1, t4
  lw t3, 0(t5)
  li a7, 1 # print_int
  mv a0, t3
  ecall
	
  li a7, 4
  la a0, str3
  ecall 
	
  addi t0, t0, 1 # i = i + 1
  j printloop
printexit:
  jr ra
#----------------------------------------------------Do not modify above text----------------------------------------------------
