.data  
fin: .asciiz "test.asm"      # filename for input
buffer: .space 1024
myString: .word 268501009
register: .space 4

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

Store: # will store teh contents of the file in $t0
	la $t0, buffer 
	li  $v0, 4           # service 4 is print string
   	add $a0, $t0, $zero  # load desired value into argument register $a0, using pseudo-op
    	syscall
    	
   	#THIS IS IS LB LOOP SETUP
    	lb $t1 , 0($t0)
	li  $v0, 11           # service 4 is print string
	add $a0, $t1, $zero  # load desired value into argument register $a0, using pseudo-op
	syscall
	
	lb $t1 , 1($t0)
	li  $v0, 11           # service 4 is print string
	add $a0, $t1, $zero  # load desired value into argument register $a0, using pseudo-op
	syscall
	
	lb $t1 , 2($t0)
	li  $v0, 11           # service 4 is print string
	add $a0, $t1, $zero  # load desired value into argument register $a0, using pseudo-op
	syscall
	
	
# Close the file

li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall            # close file
		

	
