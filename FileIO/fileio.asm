.data  
fin: .asciiz "test.asm"      # filename for input
buffer: .space 1024

register: .space 4
string1:  .space 20	# store the instruction "before the space"

.text
#open a file for writing
	li   $v0, 13       # system call for open file
	la   $a0, fin      # board file name
	li   $a1, 0        # Open for reading
	li   $a2, 0
	syscall            # open a file (file descriptor returned in $v0)
	move $s6, $v0      # save the file descriptor 

#read from file
	li   $v0, 14       # system call for read from file
	move $a0, $s6      # file descriptor 
	la   $a1, buffer   # address of buffer to which to read
	li   $a2, 1024     # hardcoded buffer length
	syscall            # read from file

Store: # will store the contents of the file in $t0
	la $t0, buffer 
	li  $v0, 4           # service 4 is print string
   	add $a0, $t0, $zero  # load desired value into argument register $a0, using pseudo-op
    	syscall
    	
LbLoop:
	li $t2, 70 # t0 is a constant THAT WE CAN CHANGE FOR THE AMOUNT OF CHARAACTERS 
	li $t3, 0 # t1 is our counter (i)
	li $s0, ' ' # load $s0 with "space"
	li $s1, ',' # load $s1 with ","
	li $s2,  '\n' # load $s2 with newline character
loop:
	
	la $t0, buffer 
	beq $t3, $t2, end # if t3 == 70 we are done
	addu $t0, $t0, $t3
    	lb $t1 , ($t0)
    	beq $t1, $s0, space # stop read if meet a "space"
	addi $t3, $t3, 1 # add 1 to t3 the counter
	j loop # jump back to the top


space: # THIS IS WHERE PARSING IS DONE FOR INSTRUCTIONS 
	la $s3, string1	
	
	lb $t7 , -4($t0)
	lb $t6 , -3($t0)
	lb $t5 , -2($t0)
	lb $t4 , -1($t0)

	sb $t7, 0($s3)
	sb $t6, 1($s3)
	sb $t5, 2($s3)
	sb $t4, 3($s3)
	
	li  $v0, 4           # service 1 is print integer
    	add $a0, $s3, $zero  # load desired value into argument register $a0, using pseudo-op
    	syscall
    	
   	addi $t3, $t3, 1 # add 1 to t3 the counter
   	j loop

# Close the file
end:
	li   $v0, 16       # system call for close file
	move $a0, $s6      # file descriptor to close
	syscall            # close file