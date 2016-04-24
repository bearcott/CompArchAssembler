.data
	fileName: .asciiz "test.asm" # filename for input
	buffer: .space 1024

.text
OpenFile: #open a file for writing
	li $v0, 13 # system call for open file
	la $a0, fileName # load file name
	li $a1, 0 # Open for reading (0 is read, 1 is write)
	li $a2, 0 # ignore mode ???
	syscall # open a file (file descriptor returned in $v0)
	move $s6, $v0 # save the file descriptor to $s6

ReadFile: #read from file
	li $v0, 14 # system call for read from file
	move $a0, $s6 # use file descriptor
	la $a1, buffer # address of buffer to which to write to
	li $a2, 1024 # hardcoded buffer length
	syscall # read from file

Store: # will store the contents of the file in $t0
	la $t0, buffer # load buffer address to $t0
	li $v0, 4 # service 4 is print string
	add $a0, $t0, $zero  # load desired value into argument register $a0, using pseudo-op
	syscall

LoadByteLoop:
	li $t1, 0 # temp char
	li $s0, ' ' # load space char
	li $s2, '\n' # load newline char
	li $s3, '\0' # null char (end of file)

loop:
	lb $t1, ($t0) # load current incremented byte from buffer
	beq $t1, $s3, end # exit if char == end of file
	li  $v0, 11 # service 11 is print char
	add $a0, $t1, $zero  # load desired value into argument register $a0, using pseudo-op
	syscall #print current character
	addi $t0, $t0, 1 # increment byte from buffer
	j loop # jump back to the top

end: #Close the file
	li $v0, 16 # system call for close file
	move $a0, $s6 # file descriptor to close
	syscall # close file
