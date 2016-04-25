#TODO: fix clumsy use of $t2 register: you have to reset it every time u use it
.data
	fileName: .asciiz "test.asm" # filename for input
	buffer: .space 1024
	tempString: .space 20

# binary values are NOT ACCURATE, need to go to mips sheet and correct them.
	ADD_OP: .asciiz "add"
	ADD_BIN: .asciiz "0000 00ss ssst tttt dddd d000 0010 0000"

	ADDI_OP: .asciiz "addi"
	ADDI_BIN: .asciiz "0010 00ss ssst tttt iiii iiii iiii iiii"
	
	ADDIU_OP: .asciiz "addiu"
	ADDIU_BIN:.asciiz  "0010 01ss ssst tttt iiii iiii iiii iiii"
	
	ADDU_OP: .asciiz "addu"
	ADDU_BIN: .asciiz "0000 00ss ssst tttt dddd d000 0010 0001"
	
	AND_OP: .asciiz "and"
	AND_BIN: .asciiz "0000 00ss ssst tttt dddd d000 0010 0100"
	
	ANDI_OP: .asciiz "andi"
	ANDI_BIN: .asciiz "0011 00ss ssst tttt iiii iiii iiii iiii"
	
	BEQ_OP: .asciiz "beq"
	BEQ_BIN:.asciiz "0001 00ss ssst tttt iiii iiii iiii iiii"
	
	BNE_OP: .asciiz "bne"
	BNE_BIN: .asciiz "0001 01ss ssst tttt iiii iiii iiii iiii"
	
	J_OP: .asciiz "j"
	J_BIN:.asciiz "0000 10ii iiii iiii iiii iiii iiii iiii"
	
	JAL_OP: .asciiz "jal"
	JAL_BIN: .asciiz "0000 11ii iiii iiii iiii iiii iiii iiii"
	
	JR_OP: .asciiz "jr"
	JR_BIN:.asciiz "0000 00ss sss0 0000 0000 0000 0000 1000"
	
	LW_OP: .asciiz "lw"
	LW_BIN:.asciiz "1000 11ss ssst tttt iiii iiii iiii iiii "
	
	ORI_OP: .asciiz "ori"
	ORI_BIN:.asciiz "0011 01ss ssst tttt iiii iiii iiii iiii"
	
	SLL_OP: .asciiz "sll"
	SLL_BIN:.asciiz "0000 00ss ssst tttt dddd dhhh hh00 0000"
	
	SRL_OP: .asciiz "srl"
	SRL_BIN:.asciiz "0000 00-- ---t tttt dddd dhhh hh00 0010"
	
	SUB_OP: .asciiz "sub"
	SUB_BIN:.asciiz "0000 00ss ssst tttt dddd d000 0010 0010"
	
	SW_OP: .asciiz "sw"
	SW_BIN:.asciiz "1010 11ss ssst tttt iiii iiii iiii iiii"
	
	SYSCALL_OP: .asciiz "syscall"
	SYCALL_BIN: .asciiz  "0000 00-- ---- ---- ---- ---- --00 1100 "
	
	S0_OP: .asciiz "$s0"
	S0_BIN: .asciiz "01030"

	S1_OP: .asciiz "$s1"
	S1_BIN: .asciiz "01500"

	S2_OP: .asciiz "$s2"
	S2_BIN: .asciiz "01510"
	
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
