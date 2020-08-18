#########################Read Image#########################
.data
			.align 2
inputTest1:		.asciiz "copy.pgm"
			.align 2
inputTest2:		.asciiz "roi_14.pgm"
			.align 2
buffer: 		.space 1024
			.align 2
struct:			.space 1024
			.align 2
error_file:		.asciiz "The file is the wrong format."

.text	
			.globl read_image
read_image:	
	# $a0 -> input file name
	
	# saving registers...
	subu $sp, $sp, 16
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	
	# opening file...
	li $v0, 13
	li $a1, 0			# set flag to read
	li $a2, 0			# ignore mode
	syscall
	move $t0, $v0			# save file descriptor
	
	# reading file...
	li $v0, 14
	move $a0, $s0			# load file decriptor
	la $a1, buffer			# load buffer
	li $a2, 1024			# buffer length
	syscall
	move $s1, $v0			# save num of chars read
	
	# closing file...
	li $v0, 16
	move $a0, $t0			# load file descriptor
	syscall

	# checking format...
	la $s0, buffer			# load pointer to buffer head
	lbu $t1, ($s0)			# load first byte
	addi $t0, $zero, 80		# $t0 = 'P'
	bne $t1, $t0, error_file	# check that first byte is 'P'
	la $s0, 1($s0)			# update pointer
	addiu $s0, $s0, 1		# update pointer
	lbu $s2, ($s0)			# s2 = format code
	
	# getting image info...
 	la $s0, 2($s0)			# update buffer pointer (skip whitespace)
	la $s3, struct			# load struct pointer 
	lbu $a0, ($s0)			# load first byte of width
	jal load_ascii
	
	lw $t0, $v0			# load width
	sw $t0, ($s3)			# store width into struct
	sw 
	
	# enter subroutine that takes a pointer to beginning of a ascii decimal
	# takes byte by byte and returns the pure binary equivalent
#############################################################################################

load_ascii: 
	# $a0 -> address of first byte of an ascii decimal
	# $v0 -> pure binary representation of the number
	addiu $t1, $zero, 0		# set t1 = 0, comparison
	addiu $t2, $zero, 0		# set t2 = 0, number
	la $t3, ($a0)			# load address of number
loop_ascii: 	
	lbu $t0, ($t3)			# load byte
	subu $t1, $t0, 48		
	bltz $t1, done_ascii		# check if byte is an ascii decimal
	subu $t1, $t0, 57		# representation of a digit 0-9
	bgtz $t1, done_ascii
	subu $t0, $t0, 48		# transform from ascii to binary
	addu $t2, $t2, $t0		# add to number
	addiu $t3, $t3, 1		# increment address
	j loop_ascii			# loop to next byte
	
done_ascii: 
	# set v0 to be the binary number
	lw $v0, ($t2)
	jr $ra
	
##############################################################################################
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	# getting width...
	bne $t3, $t6, H			# if i = 1 => width
	move $s3, $zero			# $s3 = 0
width:	addi $t2, $t2, -48		# transform $t2 from ascii code into value
	addu $s3, $s3, $t2		# add $t2 to width
	la $t1, 1($t1)			# update pointer
	lbu $t2, ($t1)			# load byte
	beq $t2, $t8, next		# if $t2 = ' ' goto next
	beq $t2, $t7, next		# if $t2 = '\n' goto next
	mul  $s3, $s3, 10		# multiply width by 10
	j width				# get next byte				
	
	# getting height...
H:	bne $t3, $t5, M			# if i = 2 => height
	move $s4, $zero			# $s4 = 0
height:	addi $t2, $t2, -48		# transform $t2 from ascii code into value
	addu $s4, $s4, $t2		# add $t2 to height
	la $t1, 1($t1)			# update pointer
	lbu $t2, ($t1)			# load byte
	beq $t2, $t8, next		# if $t2 = ' ' goto next
	beq $t2, $t7, next		# if $t2 = '\n' goto next
	mul $s4, $s4, 10		# multiply height by 10
	j height			# get next byte	
	
	
	# getting max_val...
M:	bne $t3, $t4, struct		# if i = 3 => max_val
	move $s5, $zero			# $s5 = 0
max_val:addi $t2, $t2, -48		# transform $t2 from ascii code into value
	addu $s5, $s5, $t2		# add $t2 to max_val
	la $t1, 1($t1)			# update pointer
	lbu $t2, ($t1)			# load byte
	beq $t2, $t8, next		# if $t2 = ' ' goto next
	beq $t2, $t7, next		# if $t2 = '\n' goto next
	mul $s5, $s5, 10		# multiply max_val by 10
	j max_val			# get next byte	
	
	################# return #####################
	# $v0 -> Image struct :
	# struct image {
	#	int width;
	#       int height;
	#	int max_value;
	#	char contents[width*height];
	#	}
	##############################################
	
	# creating struct...
struct:	mulu $t0, $s3, $s4		# $t0 = width x height
	addi $t0, $t0, 12		# width x height + 3*4 = memory to allocate for struct
	li $v0, 9
	move $a0, $t0 			# load size of struct
	syscall
	la $s1, ($v0)			# store address of struct
	
	# storing width, height, max_val...
	sw $s2, ($s1)			# store format code
	sw $s3, 4($s1)			# store width
	sw $s4, 8($s1)			# store height
	sw $s5, 12($s1)			# store max_val
	
	# loading contents...			
	la $a1, 1($t1)			# load pointer to contents
	addi $t5, $zero, 53		# $t5 = '5'
	addi $t4, $zero, 50		# $t4 = '2'
	
	beq $s2, $t5, load_P5		# if '5' goto P5 subroutine
	beq $s2, $t4, load_P2		# else if '2' goto P2 subroutine
	j error_file			# else error

error_file: 				# error in file format
	li $v0, 4			
	la $a0, errormsg_file
	syscall				# prints error message
	
	j exit				# exits the procedure
	
load_P5: 
	# $a1 -> first byte of contents
	# $s1 -> pointer to struct
	# 16($s1) -> start of contents
	
	la $t1, ($a1)			# load address (pgm values)
	la $t0, 16($s1)			# load pointer to contents
	addiu $t3, $zero, 0		# i = 0 
	mulu $t4, $s3, $s4		# $t4 = total num of bytes
	
	#storing contents...
loop5: 	beq $t3, $t4, exit		# if i = total num of bytes
	lbu $t2, ($t1)			# load byte
	sb $t2, ($t0)			# store byte
	addiu $t1, $t1, 1		# shift pgm pointer
	addiu $t0, $t0, 1		# shift contents pointer
	addiu $t3, $t3, 1		# i++
	j loop5
	
load_P2: 
	# $a1 -> first byte of contents
	# $s1 -> pointer to struct
	# 16($s1) -> start of contents
	
	la $t1, ($a1)			# load address (pgm values)
	la $t0, 16($s1)			# load pointer to contents
	addiu $t3, $zero, 0		# i = 0 
	mulu $t4, $s3, $s4		# $t4 = total num of bytes
	lbu $t2, ($t1)			# load byte

loop2: 	beq $t3, $t4, exit		# if i = total num of bytes
	beq $t2, $t8, update		# check if space
	beq $t2, $t7, update		# check if newline
	addi $t2, $t2, -48		# else ascii -> value
	mul $t5, $t5, 10 		# $t5 = $t5x10
	addu $t5, $t5, $t2		# $t5 = $t5 + 2
	sb $t5, ($t0)			# store value
	addiu $t1, $t1, 1		# shift pgm pointer
	lbu $t2, ($t1)			# load byte
	j loop2
	
					
update:	addiu $t1, $t1, 1		# shift pgm pointer
	addiu $t0, $t0, 1		# shift contents pointer
	addiu $t3, $t3, 1		# i++
	lbu $t2, ($t1)			# load byte
	j loop2
	
exit: 	
	move $v0, $s1			# return struct address
	
	# restoring registers...
	lw $s3, 12($sp)
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, ($sp)
	addiu $sp, $sp, 16

	jr $ra
	
