.data
add:  .asciiz "add"
subtract: .asciiz "subtract"
s0: .asciiz "$s0"
s1: .asciiz "$s1"
s2: .asciiz "$s2"
prompt1:	.asciiz	"It is add function:\n"
	.globl	main
	.text
main:
	la	$t0, add	# assume it is add
	la	$t1, s0	# assume it use $s0 as first oprand
	la	$t2, s1	# assume it use $s1 as second oprand
	la	$t3, s2	# assume it use $s2 as third oprand

Add:
	la	$t4, add		# enumerate all the function, first try add function
	bne	$t4, $t0, Minus	# if not add, then try minus and so on

				# for test only
	li	$v0, 4		# system call code for print string
	la	$a0, prompt1	# load address of prompt1 into $a0
	syscall			# call operating system to perform operation

	addi	$s0, $zero, 20	# $s0 store op code
	jal	findReg1		# repeatedly find the reg1
	jal	findReg2		# repeatedly find the reg2
	jal	findReg3		# repeatedly find the reg3
	sll	$s1, $s1, 21	# shift left to get the correct position
	sll	$s2, $s2, 16
	sll	$s3, $s3, 11
	or	$s0, $s0, $s1	# use "or" to get the final value
	or	$s0, $s0, $s2
	or	$s0, $s0, $s3
	move	$v0, $s0
	li	$v0, 1 		# system call code for read integer
	syscall
	jal	end

Subtract:
	la	$a1, subtract
	bne	$t4, $t0, And

And:

findReg1:
	la	$t5, s0
	addi	$s1, $zero, 17
	beq	$t5, $t1, exit
	la	$t5, s1
	addi	$s1, $zero, 18
	beq	$t5, $t1, exit
	la	$t5, s2
	addi	$s1, $zero, 19
	beq	$t5, $t1, exit

findReg2:
	la	$t5, s0
	addi	$s2, $zero, 17
	beq	$t5, $t1, exit
	la	$t5, s1
	addi	$s2, $zero, 18
	beq	$t5, $t1, exit
	la	$t5, s2
	addi	$s3, $zero, 19
	beq	$t5, $t1, exit

findReg3:
	la	$t5, s0
	addi	$s3, $zero, 17
	beq	$t5, $t1, exit
	la	$t5, s1
	addi	$s3, $zero, 18
	beq	$t5, $t1, exit
	la	$t5, s2
	addi	$s3, $zero, 19
	beq	$t5, $t1, exit

exit:
	jr	$ra

end:
	li	$v0, 10		# terminate program
	syscall			# call operating system to perform operation
