#########################Read Image#########################
.data
		.align 2
buffer:		.space 1024
		.align 2
struct:		.space 1024		# max space = 3 + 255^2
		.align 2
errorOpen: 	.asciiz "There was an error opening the file."
		.align 2
errorRead: 	.asciiz	"There was an error reading the file."

.text
		.globl read_image
read_image:
	# $a0 -> input file name
	################# return #####################
	# $v0 -> Image struct :
	# struct image {
	#	int width;
	#       int height;
	#	int max_value;
	#	char contents[width*height];
	#	}
	##############################################\
	
	# save $s registers
	subu $sp, $sp, 12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	
	# open file
	li $v0, 13			# syscall to open file
	li $a1, 0			# set flag to read
	li $a2, 0			# ignore mode
	syscall
	move $s0, $v0			# save file descriptor
	# checking for errors
	slt $t0, $v0, $zero		# if $v0 < 0 (error)
	bne $t0, $zero, error_open	# go to error message
	
	# read byte into buffer
	li $v0, 14
	move $a0, $s0			# load file descriptor
	la $a1, buffer			# load buffer address
	li $a2, 1024			# max num of chars to read
	syscall
	# checking for errors
	slt $t0, $v0, $zero		# if $v0 < 0 (error)
	bne $t0, $zero, error_read	# go to error message
	move $s1, ($v0)			# save number of bytes read
	
	# close file
	li $v0, 16
	move $a0, $s0			# load file descriptor
	syscall
	
	# load image info
	addi $t0, $s1, 0		# set t = num of bytes read
	la $s2, buffer			# load buffer address
	lb $t1, ($s2)			# load first byte into t1
					# first byte is 'P' so we can throwaway
	subu $t0, $t0, 1		# decrement t0
	addu $s2, $s2, 1		# increment buffer address
	lb $t1, ($s2)			# load code into t1: 2 or 5
	
	# load contents
	
	# load $s registers
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addu $sp, $sp, 12
	
	jr $ra
	
error_open: 
	li $v0, 4			# print error message
	la $a0, errorOpen
	syscall
	
	jr $ra 				# exit subroutine
	
error_read:
	li $v0, 4			# print error message
	la $a0, errorRead
	syscall
	
	jr $ra 				# exit subroutine
