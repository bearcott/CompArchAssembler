.data  
fin: .asciiz "test.asm"      # filename for input
buffer: .space 1024
myString: .word 268501009
register: .space 4
prompt1:	.asciiz	"****************************************************\n" 
string1:	.space 16
string2:	.space 16
string3:	.space 16
string4:	.space 16
s0:	.asciiz	"$s0"
s1:	.asciiz	"$s1"
s2:	.asciiz	"$s2"

add:	.asciiz	"add"
minus:	.asciiz	"minus"

.text
#open a file for writing
	li   $v0, 13       # system call for open file
	la   $a0, fin      # board file name
	li   $a1, 0        # Open for reading
	li   $a2, 0
	syscall            # open a file (file descriptor returned in $v0)
	move $s7, $v0      # save the file descriptor 

#read from file
	li   $v0, 14       # system call for read from file
	move $a0, $s7      # file descriptor 
	la   $a1, buffer   # address of buffer to which to read
	li   $a2, 1024     # hardcoded buffer length
	syscall            # read from file	
	
Store: # will store the contents of the file in $t0
    	
	li	$v0, 4		# system call code for print string
	la	$a0, prompt1	# load address of prompt1 into $a0 
	syscall			# call operating system to perform operation

LbLoop:
	li $t2, 70 # t0 is a constant THAT WE CAN CHANGE FOR THE AMOUNT OF CHARAACTERS 
	li $t3, 0 # t1 is our counter (i)
	li $t7, ' '	# load $s0 with "space"
	li $t8, ','	# load $s1 with ","
	li $t9,  '\n'	# load $s2 with newline character
	la $s4, string1
	la $s5, string2
	la $s6, string3
	la $t6, string4
	
	la $t0, buffer
		
loop1:	 	#store first op function into string1
    	lb $t1, ($t0)
    	addi $t0, $t0, 1
    	beq $t1, $t7, loop2 #skip space  	
    	sb $t1, ($s4)	
    	addi $s4, $s4, 1	
	j loop1 	# jump back to the top
	
loop2:		#store first oprand into string2		   	
    	lb $t1, ($t0)
        	addi $t0, $t0, 1
    	beq $t1, $t8, loop3	#skip ,   	
    	sb $t1, ($s5)
	addi $s5, $s5, 1	
	j loop2 	# jump back to the top

loop3:		#store second oprand into string3
	lb $t1, ($t0)
        	addi $t0, $t0, 1
    	beq $t1, $t8, loop4	#skip ,   	
    	sb $t1, ($s6)
	addi $s6, $s6, 1	
	j loop3 	# jump back to the top
		
loop4:		#store third oprand into string5
    	lb $t1, ($t0)
    	addi $t0, $t0, 1
    	beq $t1, $t9, Add	#skip newline  	
    	sb $t1, ($t6)
    	addi $t6, $t6, 1		
	j loop4 	# jump back to the top			

Add:		
	#need a function to compare two string, byte by byte!
	
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
	move	$a0, $s0
	li	$v0, 1 		# system call code for print integer
	syscall	
	jal	loop1
	
findReg1:
	#need a function to compare two string, byte by byte!

findReg2:
	#need a function to compare two string, byte by byte!

findReg3:
	#need a function to compare two string, byte by byte!
	
exit:
	jr	$ra	
		
Minus:										
										
												
														
																		
# Close the file
end:	
	# for test only
	li	$v0, 4		# system call code for print string
	la	$a0, string1	# load address
	syscall			# call operating system to perform operation
	
	li	$v0, 4		# system call code for print string
	la	$a0, string2	# load address
	syscall			# call operating system to perform operation
	
	li	$v0, 4		# system call code for print string
	la	$a0, string3	# load address
	syscall			# call operating system to perform operation
	
	li	$v0, 4		# system call code for print string
	la	$a0, string4	# load address
	syscall			# call operating system to perform operation
	
	
	
	li   $v0, 16       # system call for close file
	move $a0, $s7     # file descriptor to close
	syscall            # close file
