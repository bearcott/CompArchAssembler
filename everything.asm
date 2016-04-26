#TODO: fix clumsy use of $t2 register: you have to reset it every time u use it
.data
	fileName: .asciiz "test.asm" # filename for input
	buffer: .space 1024
	tempString: .space 20

# binary values are NOT ACCURATE, need to go to mips sheet and correct them.
	ADD_OP: .asciiz "add"
	ADD_BIN: .asciiz "11141"

	S0_OP: .asciiz "$s0"
	S0_BIN: .asciiz "01030"

	S1_OP: .asciiz "$s1"
	S1_BIN: .asciiz "01500"

	S2_OP: .asciiz "$s2"
	S2_BIN: .asciiz "01510"
	
	ZERO_OP: .asciiz "$zero"
	ZERO_BIN: .asciiz "000000"

	AT_OP: .asciiz "$at"
	AT_BIN: .asciiz "000001"

	V0_OP: .asciiz "$v0"
	V0_BIN: .asciiz "000010"

	V1_OP: .asciiz "$v1"
	V1_BIN: .asciiz "000011"

	A0_OP: .asciiz "$a0"
	A0_BIN: .asciiz "000100"

	A1_OP: .asciiz "$a1"
	A1_BIN: .asciiz "000101"

	A2_OP: .asciiz "$a2"
	A2_BIN: .asciiz "000110"

	A3_OP: .asciiz "$a3"
	A3_BIN: .asciiz "000111"

	T0_OP: .asciiz "$t0"
	T0_BIN: .asciiz "001000"

	T1_OP: .asciiz "$t1"
	T1_BIN: .asciiz "001001"

	T2_OP: .asciiz "$t2"
	T2_BIN: .asciiz "001010"

	T3_OP: .asciiz "$t3"
	T3_BIN: .asciiz "001011"

	T4_OP: .asciiz "$t4"
	T4_BIN: .asciiz "001100"

	T5_OP: .asciiz "$t5"
	T5_BIN: .asciiz "001101"

	T6_OP: .asciiz "$t6"
	T6_BIN: .asciiz "001110"

	T7_OP: .asciiz "$t7"
	T7_BIN: .asciiz "001111"
	
	S0_OP: .asciiz "$s0"
	S0_BIN: .asciiz "010000"

	S1_OP: .asciiz "$s1"
	S1_BIN: .asciiz "010001"

	S2_OP: .asciiz "$s2"
	S2_BIN: .asciiz "010010"

	S3_OP: .asciiz "$s3"
	S3_BIN: .asciiz "010011"

	S4_OP: .asciiz "$s4"
	S4_BIN: .asciiz "010100"

	S5_OP: .asciiz "$s5"
	S5_BIN: .asciiz "010101"

	S6_OP: .asciiz "$s6"
	S6_BIN: .asciiz "010110"

	S7_OP: .asciiz "$s7"
	S7_BIN: .asciiz "010111"

	T8_OP: .asciiz "$t8"
	T8_BIN: .asciiz "011000"

	T9_OP: .asciiz "$t9"
	T9_BIN: .asciiz "011001"
	
	GP_OP: .asciiz "$gp"
	GP_BIN: .asciiz "011100"

	SP_OP: .asciiz "$sp"
	SP_BIN: .asciiz "011101"

	FP_OP: .asciiz "$fp"
	FP_BIN: .asciiz "011110"

	RA_OP: .asciiz "$ra"
	RA_BIN: .asciiz "011111"

.macro printString(%arg)
	li $v0, 4 # service 4 is print string
	add $a0, %arg, $zero  # load desired value into argument register $a0, using pseudo-op
	syscall
	printNewLine()
.end_macro

.macro printNewLine
	addi $a0, $0, 0xA #ascii code for LF, if you have any trouble try 0xD for CR.
	addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
	syscall
.end_macro

.macro printChar(%arg)
	li $v0, 11 # service 11 is print char
	add $a0, %arg, $zero  # load desired value into argument register $a0, using pseudo-op
	syscall
	printNewLine()
.end_macro

.macro handleComparison(%string, %binary)
	la $t2, tempString
	la $t3, %string
	la $t4, %binary
	jal comparePhraseLoop
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
	li $t1, 0 # reserved for temp chars
	la $t2, tempString # tempString to store phrase every time a delimiter is met
	li $t3, 0 # reserved for holding address of temp phrases
	li $t4, 0 # reserved for holding address of temp binary output
	li $t5, 0 # reserved for second temp char

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

	sb $t1, ($t2) # store current byte into tempstring
	addi $t0, $t0, 1 # increment byte from buffer
	addi $t2, $t2, 1 # increment tempstring byte
	j byteLoop # jump back to the top


comparePhraseLoop: #handle each character
	lb $t1, ($t2) # get character from temp phrase
	lb $t5, ($t3) # get character from comparing phrase
	bne $t1, $t5, comparePhraseElse # exit if char != compared char
	beq $t1, $s3, comparePhraseDone # exit if char == null, phrase is complete
	# printChar($t5)
	# printChar($t1)
	addi $t2, $t2, 1 # increment through the phrase
	addi $t3, $t3, 1 # increment hardcoded phrase
	j comparePhraseLoop
comparePhraseElse:
	jr $ra
comparePhraseDone:
	#perform ouput operation here
	printString($t4)
	jr $ra

emptyPhraseLoop:
	lb $t1, ($t2) # get character from temp phrase
	sb $s3, ($t2) # set char to null for next iteration, this way the phase will be empty
	beq $t1, $s3, emptyPhraseDone # exit if char == null, phrase is complete
	addi $t2, $t2, 1 # increment through the phrase
	j emptyPhraseLoop
emptyPhraseDone:
	jr $ra

handleSpace: # op codes go here
	addi $t0, $t0, 1 # increment byte from buffer to skip the space

	#brute force & hardcoded my nigga
	#TODO: not use macro for something so bullshit
	handleComparison(ADD_OP,ADD_BIN)

	la $t2, tempString # reset the counter and get the phrase
	jal emptyPhraseLoop
	la $t2, tempString # reset the counter again
	j byteLoop


handleComma: # arguments go here
	addi $t0, $t0, 1 # increment byte from buffer to skip the comma
	printString($t2)
	handleComparison(S0_OP,S0_BIN)
	handleComparison(S1_OP,S1_BIN)
	handleComparison(S2_OP,S2_BIN)
	handleComparison(S3_OP,S3_BIN)
	handleComparison(S4_OP,S4_BIN)
	handleComparison(S5_OP,S5_BIN)
	handleComparison(S6_OP,S6_BIN)
	handleComparison(S7_OP,S7_BIN)
	handleComparison(AT_OP,AT_BIN)
	handleComparison(V0_OP,V0_BIN)
	handleComparison(V1_OP,V1_BIN)
	handleComparison(A0_OP,A0_BIN)
	handleComparison(A1_OP,A1_BIN)
	handleComparison(A2_OP,A2_BIN)
	handleComparison(T1_OP,T1_BIN)
	handleComparison(T2_OP,T2_BIN)
	handleComparison(T3_OP,T3_BIN)
	handleComparison(T4_OP,T4_BIN)
	handleComparison(T5_OP,T5_BIN)
	handleComparison(T6_OP,T6_BIN)
	handleComparison(T7_OP,T7_BIN)
	handleComparison(T8_OP,T8_BIN)
	handleComparison(T9_OP,T9_BIN)
	handleComparison(GP_OP,GP_BIN)
	handleComparison(SP_OP,SP_BIN)
	handleComparison(FP_OP,FP_BIN)
	handleComparison(RA_OP,RA_BIN)

	la $t2, tempString # reset the counter and get the phrase
	jal emptyPhraseLoop
	la $t2, tempString # reset the counter again
	j byteLoop

handleNewLine: # new instructions
	addi $t0, $t0, 1 # increment byte from buffer to skip the newline
	printString($t2)

	la $t2, tempString # reset the counter and get the phrase
	jal emptyPhraseLoop
	la $t2, tempString # reset the counter again
	j byteLoop


end: #Close the file
	li $v0, 16 # system call for close file
	move $a0, $s6 # file descriptor to close
	syscall # close file
