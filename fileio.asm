#Student ID = 260799839
############################ Q1: file-io########################
.data
			.align 2
inputTest1:		.asciiz "test1.txt"
			.align 2
inputTest2:		.asciiz "test2.txt"
			.align 2
outputFile:		.asciiz "copy.pgm"
			.align 2
buffer:			.space 1024

# my own stuff
			.align 2
info: 			.ascii "P2 \n24 7 \n15\n"
			.align 2
errorOpen: 		.asciiz "There was an error opening the file."
			.align 2
errorRead: 		.asciiz	"There was an error reading the file."
			.align 2
errorWrite: 		.asciiz	"There was an error writing to the file."

.text
.globl fileio

fileio:
	
	la $a0,inputTest1
	#la $a0,inputTest2
	jal read_file
	
	la $a0,outputFile
	jal write_file
	
	li $v0,10		# exit...
	syscall	
		

	
read_file:
	# $a0 -> input filename
	# opening file...
	li $v0, 13			# opens file
	li $a1, 0			# set flag to read
	li $a2, 0			# ignore mode
	syscall
	move $t0, $v0			# save file descriptor
	# checking for errors
	slt $t1, $v0, $zero		# if $v0 < 0 (error)
	bne $t1, $zero, error_open	# go to error message
	
	
	# reading file into buffer...
	li $v0, 14
	move $a0, $t0			# load file descriptor
	la $a1, buffer			# load buffer address
	li $a2, 1024			# max num of chars to read
	syscall
	# checking for errors
	slt $t1, $v0, $zero		# if $v0 < 0 (error)
	bne $t1, $zero, error_read	# go to error message
	
	# printing file contents...
	li $v0, 4
	la $a0, buffer			# loading buffer to print
	syscall
	
	# closing file...
	li $v0, 16
	move $a0, $t0			# load file descriptor
	syscall
	
	#return
	jr $ra
	
write_file:
	# $a0 -> outputFilename
	# opening file for writing...
	li $v0, 13
	li $a1, 1			# set flag to write
	li $a2, 0			# ignore mode
	syscall
	move $t0, $v0			# save file descriptor
	# checking for errors
	slt $t1, $v0, $zero		# if $v0 < 0 (error)
	bne $t1, $zero, error_open	# go to error message
	
	# write following contents:
	# P2
	# 24 7
	# 15
	
	# writing to file... (words)
	li $v0, 15
	move $a0, $t0			# load file descriptor
	la $a1, info			# load content to write
	li $a2, 16			# buffer length
	syscall
	# checking for errors
	slt $t1, $v0, $zero		# if $v0 < 0 (error)
	bne $t1, $zero, error_write	# go to error message
	
	# writing to file... (buffer)
	li $v0, 15
	move $a0, $t0			# load file descriptor
	la $a1, buffer			# load buffer to write
	li $a2, 1024			# buffer length
	syscall
	# checking for errors
	slt $t1, $v0, $zero		# if $v0 < 0 (error)
	bne $t1, $zero, error_write	# go to error message
	
	# closing file...
	li $v0, 14
	move $a0, $t0			# load file descriptor
	syscall
	
	#return
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
	
	jr $ra 				# exit read_file

error_write:
	li $v0, 4			# print error message
	la $a0, errorWrite
	syscall
	
	jr $ra 				# exit write_file

		  	  
