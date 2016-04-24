.data
	fileName: .asciiz "test.asm" # filename for input
	buffer: .space 1024
	tempString: .space 20

.macro printString(%arg)
li $v0, 4 # service 4 is print string
add $a0, %arg, $zero  # load desired value into argument register $a0, using pseudo-op
syscall
.end_macro

.text
openFile: #open a file for writing
	li $v0, 13 # system call for open file
	la $a0, fileName # load file name
	li $a1, 0 # Open for reading (0 is read, 1 is write)
	li $a2, 0 # ignore mode ???
	syscall # open a file (file descriptor returned in $v0)
	move $s6, $v0 # save the file descriptor to $s6

readFile: #read from file
	li $v0, 14 # system call for read from file
	move $a0, $s6 # use file descriptor
	la $a1, buffer # address of buffer to which to write to
	li $a2, 1024 # hardcoded buffer length
	syscall # read from file

loadByteLoop:
	la $t0, buffer # load buffer address in $t0
	li $t1, 0 # temp char
	la $t2, tempString
	li $s0, ' ' # load space char
	li $s1, ',' # load space char
	li $s2, '\n' # load newline char
	li $s3, '\0' # null char (end of file)

	#print the buffer
	printString($t0)

byteLoop:
	lb $t1, ($t0) # load current incremented byte from buffer
	beq $t1, $s3, end # exit if char == end of file
	beq $t1, $s2, handleNewLine # if char == newline go to handler
	beq $t1, $s1, handleComma # if char == comma go to handler
	beq $t1, $s0, handleSpace # if char == space go to handler
	sb $t1, ($t2) # store current byte into string

	# li $v0,11 # service 11 is print char
	# add $a0, $t1, $zero  # load desired value into argument register $a0, using pseudo-op
	# syscall #print current character

	addi $t0, $t0, 1 # increment byte from buffer
	addi $t2, $t2, 1 # increment tempstring byte
	j byteLoop # jump back to the top

handleSpace:
	addi $t0, $t0, 1 # increment byte from buffer to skip the space
	la $t2, tempString # get the current op and reset the counter
	# handleSpaceLoop:
	# 	beq $t2,

	printString($t2)

	j byteLoop

handleComma:
	addi $t0, $t0, 1 # increment byte from buffer to skip the comma
	la $t2, tempString # get the current op and reset the counter
	printString($t2)
	j byteLoop

handleNewLine:
	addi $t0, $t0, 1 # increment byte from buffer to skip the newline
	la $t2, tempString # get the current op and reset the counter
	printString($t2)
	j byteLoop


end: #Close the file
	li $v0, 16 # system call for close file
	move $a0, $s6 # file descriptor to close
	syscall # close file
