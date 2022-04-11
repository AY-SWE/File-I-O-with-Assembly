######### Andy Yang ##########
######### 112890582 ##########
######### andyyang ##########

######## DO NOT ADD A DATA SECTION ##########
######## DO NOT ADD A DATA SECTION ##########
######## DO NOT ADD A DATA SECTION ##########

.text
################################## PART 1 ###########################
.globl initialize
initialize:
	addi $sp, $sp, -20 # allocate space on stack
	sw $ra, 0($sp)
	sw $s0, 4($sp)	#save s0 onto stack
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	
	move $s0, $a0	# a0 contains a string filename, moved into s0
	move $s1, $a1	# a1 contains address to buffer, move into $s1
	move $s2, $a1	# s2 contains original buffer, in case error, buffer must remain unchanged
	
	#opening file
	li $v0, 13	#13 is syscall to open file
	li $a1, 0	# 0 is for read, 1 is write,
	li $a2, 0 	# a2 should be ignored, should be 0
	syscall 	#perform the open of file
	
	bltz $v0, part1_error	#-1 means error occured
	
	move $t0, $v0   # v0 contains file descriptor if no error occured, move into t0
	addi $sp, $sp, -1 	#add one more for space to read file
	move $s3, $sp
	
	li $t1, 0		# t1 # of rows
	li $t2, 0			# t2 # of columns
	li $t3, 1 	# temp for write row or column, 1 for row, 2 for column
	li $t7, 1	# for checking t3
	li $t8, 2	# for checking t3
	li $t9, 0	# counter
	
part1_read_file:
	li $v0, 14 #syscall 14 is read file
	li $a2, 1	# number of characters to read, should be 1
	move $a0, $t0   #t0 contained file descriptor, move into a0 for sycall 14
	move $a1, $s3	#move s4(contains address of buffer)into a1 for syscall 14
	syscall
	
	bltz $v0, part1_error
	beqz $v0, part1_finish_read_file   # 0 means end of file
	beq $t3, $t7, count_rows
	beq $t3, $t8, count_columns
	
	lb $t4, 0($s3)  # get current character being read
	
	li $t6, '\r'		
	beq $t4, $t6, part1_read_file
	li $t6, '\n'		
	beq $t4, $t6, part1_read_file
	
	li $t6, '0'   #$t6 == '0'
	blt $t4, $t6, part1_invalid_char  #if less than 0, invalid
	li $t6, '9'   
	bgt $t4, $t6, part1_invalid_char   #if $t4 is > '9',invalid
	
	addi $t4, $t4, -48  #convert to integer
	sb $t4, 0($s1)
	addi $s1, $s1, 4	#increment s1 address of buffer by 4 to store that chracter as integer
	addi $t9, $t9, 1
	j part1_read_file
	
count_rows:	
	lb $t4, 0($s3)		
	
	li $t6, '\r'		
	beq $t4, $t6, part1_read_file
	li $t6, '\n'		
	beq $t4, $t6, count_rows_done
	
	li $t6, '1'   #$t6 == '1'
	blt $t4, $t6, part1_invalid_char  #if less than 0, invalid
	li $t6, '9'   
	bgt $t4, $t6, part1_invalid_char   #if $t4 is > '9',invalid
	
	
	addi $t4, $t4, -48	#t1 is for # of rows,  convert string to integer value, ex: '1' is 49 thus 49 +(-48) = 1
	li $t5, 10
	mul $t1, $t1, $t5
	add $t1, $t1, $t4  # add with the new number read in t4
	j part1_read_file
			
count_rows_done:
	li $t3, 2	#change to 3, so it will start counting columns
	sw $t1, 0 ($s1)	 # note: $s1 contains address of buffer
	addi $s1, $s1, 4 	#increment by 4 in the address, since integer takes 4 bytes
	addi $t9, $t9, 1
	j part1_read_file
			
count_columns:
	lb $t4, 0($s3) 	# t4 holds the reading current character
	
	li $t6, '\r'	
	beq $t4, $t6, part1_read_file
	li $t6, '\n'
	beq $t4, $t6, count_columns_done	# in windwos, its \r(13) then \n (10)
	
	li $t6, '1'   #$t6 == '1'
	blt $t4, $t6, part1_invalid_char  #if less than 0, invalid
	li $t6, '9'   
	bgt $t4, $t6, part1_invalid_char   #if $t4 is > '9',invalid
	
	
	addi $t4, $t4, -48	#convert char in t4 into integer
	li $t5, 10	# in case it's a 2 digit number
	mul $t2, $t2, $t5	#t2 will hold # of columns
	add $t2, $t2, $t4  # add with the new number read in t4
	j part1_read_file
	
count_columns_done:
	li $t3, -1    # neither 1 or 2, so skip count rows and columns 
	sw $t2, 0($s1)
	addi $s1, $s1, 4 	#increment by 4 in the buffer address, since integer takes 4 bytes
	addi $t9, $t9, 1
	j part1_read_file
	
part1_invalid_char:
	li $v0, 16   #16 is close file syscall
	move $a0, $t0   # t0 contains file descrip., move into a0 to close it
	syscall
	addi $sp, $sp, 1	#deallocate stack that was used to read file 
	j part1_error
	
part1_finish_read_file:
	li $v0, 16   #16 is close file syscall
	move $a0, $t0   # t0 contains file descrip., move into a0 to close it
	syscall
	addi $sp, $sp, 1	#deallocate stack that was used to read file
	li $v0, 1	# 1 because no errors occured 
	j part1_exit

part1_error:
	li $v0, -1 # error, so load -1 into v1 which will be returned
	li $t8, 0 	# reset t8 
	move $a1, $s2
	j part1_error_loop

part1_error_loop:
	lw $t8, 0($a1)
	beq $t9, $0, part1_exit
	sw $0, 0($a1)
	addi $a1, $a1, 4
	addi $t9, $t9, -1
	j part1_error_loop
	
part1_exit: 
	move $a0, $s0		#move filename back into a0
	move $a1, $s2		#move original buffer back into $a1
	lw $s3, 16($sp)
	lw $s2, 12($sp)
	lw $s1, 8($sp)	#reload s1 original value back into s1
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 20 #deallocate stack 
 	jr $ra

################################## PART 2 ###########################
.globl write_file
write_file:
	addi $sp, $sp, -352 # allocate space on stack
	sw $ra, 0($sp)
	sw $s0, 4($sp)	#save s0 onto stack
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)		#s3 was not used
	
	move $s0, $a0	# a0 contains output filename, moved into s0 
	move $s1, $a1	# a1 contains address to buffer, move into $s1
	move $s2, $a1	# s2 contains original buffer
	
	addi $t9, $sp, 20		
	
	#opening file
	li $v0, 13	#13 is syscall to open file
	li $a1, 1	# 0 is for read, 1 is write,
	li $a2, 0 	# a2 should be ignored, should be 0
	syscall 	#perform the open of file
	
	bltz $v0, part2_error	#-1 means error occured
	
	move $t0, $v0   # v0 contains file descriptor if no error occured, move into t0
	addi $sp, $sp, -1 	#add one more for space to write file
	
part2_write_file_row_and_column:
	lw $t1, 0($s1)		# load row from buffer(s1) into t1
	move $t6, $t1		#move # of rows into t6
	addi $t1, $t1, 48	#convert integer to char to store into a0(filename)
	sb $t1, 0($t9)		#s1 contains buffer, store char back into buffer
	li $v0, 15 #syscall 15 is write file
	li $a2, 1	# number of characters to write, should be 1
	move $a0, $t0   #t0 contained file descriptor, move into a0 for sycall 15
	move $a1, $t9	#s1 contains the buffer from which to write
	syscall
	bltz $v0, part2_error	#-1 means error occured
	
	li $t1, '\n'
	sb $t1, 0($t9)		#s1 contains buffer, store char back into buffer
	li $v0, 15 #syscall 15 is write file
	li $a2, 1	# number of characters to write, should be 1
	move $a0, $t0   #t0 contained file descriptor, move into a0 for sycall 15
	move $a1, $t9	#move t9(contains sp) into a1 for syscall 15
	syscall
	bltz $v0, part2_error	#-1 means error occured
	addi $s1, $s1, 4	#move to next intger in buffer
	
	lw $t1, 0($s1)		# load column from buffer(s1) into t1
	move $t7, $t1		#move # of columns into t7
	move $t5, $t1		#move # of columns into t5
	addi $t1, $t1, 48	#convert integer to char to store into a0(filename)
	sb $t1, 0($t9)		#s1 contains buffer, store char back into buffer
	li $v0, 15 #syscall 15 is write file
	li $a2, 1	# number of characters to write, should be 1
	move $a0, $t0   #t0 contained file descriptor, move into a0 for sycall 15
	move $a1, $t9	#move s3(contains sp) into a1 for syscall 15
	syscall
	bltz $v0, part2_error	#-1 means error occured
	
	li $t1, '\n'
	sb $t1, 0($t9)		#s1 contains buffer, store char back into buffer
	li $v0, 15 #syscall 15 is write file
	li $a2, 1	# number of characters to write, should be 1
	move $a0, $t0   #t0 contained file descriptor, move into a0 for sycall 15
	move $a1, $t9	#move s3(contains sp) into a1 for syscall 15
	syscall
	bltz $v0, part2_error	#-1 means error occured
	addi $s1, $s1, 4	#move to next intger in buffer
	
part2_write_loop:
	beq $t6, $0, part2_done	#t6 holds rows
	beq $t7, $0, part2_next_row	#t7 holds columns
	lw $t1, 0($s1)		# load column from buffer(s1) into t1
	addi $t1, $t1, 48	#convert integer to char to store into a0(filename)
	sb $t1, 0($t9)		#s1 contains buffer, store char back into buffer
	li $v0, 15 #syscall 15 is write file
	li $a2, 1	# number of characters to write, should be 1
	move $a0, $t0   #t0 contained file descriptor, move into a0 for sycall 15
	move $a1, $t9	#move s3(contains sp) into a1 for syscall 15
	syscall
	bltz $v0, part2_error	#-1 means error occured
	addi $s1, $s1, 4	#move to next integer in buffer
	addi $t7, $t7, -1
	j part2_write_loop

part2_next_row:
	li $t1, '\n'
	sb $t1, 0($t9)		#s1 contains buffer, store char back into buffer
	li $v0, 15 		#syscall 15 is write file
	li $a2, 1	# number of characters to write, should be 1
	move $a0, $t0   #t0 contained file descriptor, move into a0 for sycall 15
	move $a1, $t9	#move s3(contains sp) into a1 for syscall 15
	syscall
	addi $t6, $t6, -1	#decrement number of rows
	move $t7, $t5		#reset number of columns in t6
	j part2_write_loop

part2_done:
	li $v0, 16   #16 is close file syscall
	move $a0, $t0   # t0 contains file descrip., move into a0 to close it
	syscall
	addi $sp, $sp, 1	#deallocate stack used to write file
	li $v0, 1	# 1 because no errors occured 
	move $a1, $s2	#move orignal buffer in s2 to a0(filename)
	move $a0, $s0	#move orignal filename in s0 back to a0(filename)
	j part2_exit
	
part2_error:
	li $v0, 16   #16 is close file syscall
	move $a0, $t0   # t0 contains file descrip., move into a0 to close it
	syscall
	addi $sp, $sp, 1	#deallocate stack used to write file
	li $v0, -1 # error, so load -1 into v1 which will be returned
	move $a1, $s2		#s2 contains original buffer
	j part2_exit
	
part2_exit: 
	lw $ra, 0($sp)
	lw $s0, 4($sp)	#save s0 onto stack
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 352 # deallocate space on stack
 	jr $ra

################################## PART 3 ##################################
.globl rotate_clkws_90
rotate_clkws_90:
	li $s1, 0
	li $s2, 0
	li $s3, 0
	li $s4, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	li $t8, 0
	li $t9, 0
	addi $sp, $sp, -352 # allocate space on stack	(9*9)= 81 +2= 83 *4(because storing integers)= 332, + 20 = 352 
	sw $ra, 0($sp)
	sw $s1, 4($sp)	#save s1 onto stack
	sw $s2, 8($sp)	# s2 will be used to store number of rows
	sw $s3, 12($sp)	# s3 will be used to store number of columns
	sw $s4, 16($sp)
	move $s1, $a0	# a0 contains address to buffer, move into $s1
	move $s4, $a1	# a1 has filename (output.txt)

	addi $t2, $sp, 20   # beginning of an array that will hold the rotated buffer
	move $t9, $t2		# t9 will hold starting point of t2(the rotated array)
	move $t8, $t2		# also starting point of t2, need this to swap row and col in output.txt
	move $a1, $s1

rotate_90_get_row_and_column:
	lw $t1, 0($a0)		# load row from buffer(a1) into t1
	move $s2, $t1		#move # of rows into s2
	sw $t1, 0($t2)		#store # of row to t2(beginning of array)  
	addi $t2, $t2, 4
	addi $a0, $a0, 4
	
	lw $t1, 0($a0)		# load column from buffer(a1) into t1
	move $s3, $t1		#move # of columns into s3
	sw $t1, 0($t2)		#store # of columns to t2(beginning of array)
	addi $t2, $t2, 4
	addi $a0, $a0, 4
	li $t4, 0
	
rotate90_loop:
	 beq $t4, $t1, end_loop		# t4 is columns counter, done with entire matrix when t4 = # of columns
	 move $t3, $s2	# set t3 to # of row, used for row counter
	addi $t3, $t3, -1  #since index i and j both start at 0 	
	 
rotate90_col_loop:
	blt $t3, $0, rotate90_col_increment	# t3(row) less than 0, done with the column, move to next column
	mul $t5, $t3, $t1	#t5 = i(row) * (s3)# of columns
	add $t5, $t5, $t4	#t6 = (i(row) * (s3)# of columns + j(column))
	sll $t5, $t5, 2		# mulitply by elements in bytes (4 b/c intger)
	add $t6, $a0, $t5	# t7 = base addr + $t6  
	lw $t7, 0($t6)		#(the desired element)
	sw $t7, 0($t2)	
	addi $t2, $t2, 4	# move to next integer slot 
	addi $t3, $t3, -1
	j rotate90_col_loop

rotate90_col_increment:
	addi $t4, $t4, 1		#t4 contains column counter
	j rotate90_loop
	
end_loop:
	sw $s3, 0($t8)	#swap row and column in buffer
	addi $t8, $t8, 4
	sw $s2, 0($t8)
	move $a1, $t9	#move t9 (points to start of rotated buffer buffer) back into a1 for write_file	
	move $a0, $s4	#move out.txt back into a0 for write_file	
	jal write_file		#a0 has output.txt, a1 has buffer, good to jal write_file
	j part3_exit
		
part3_exit:
	move $a0, $t9	#move beginning of rotated t9 back into a0
	move $a1, $s4	#move out.txt back into a0
	lw $ra, 0($sp)
	lw $s1, 4($sp)	#reload s1 original value back into s1
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	addi $sp, $sp, 352 #deallocate stack 
 	jr $ra

################################## PART 4 ####################################
.globl rotate_clkws_180
rotate_clkws_180:
	addi $sp, $sp, -4 # allocate space on stack
	sw $ra, 0($sp)
	
	jal rotate_clkws_90
	move $t9, $a0	#move rotated buffer into t9
	move $a0, $a1	#move output.txt into $a0 to run initialize
	move $a1, $t9
	jal initialize
	move $t9, $a0	#move filename into t9
	move $a0, $a1	#move buffer into $a0 to run rotate90 again
	move $a1, $t9
	jal rotate_clkws_90
	j part4_exit
	
part4_exit:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	move $a0, $s1	#move s1 original buffer back into a1 
	move $a1, $s4	#move out.txt back into a0
 	jr $ra

################################## PART 5 ###########################
.globl rotate_clkws_270
rotate_clkws_270:
	addi $sp, $sp, -4 # allocate space on stack
	sw $ra, 0($sp)
	
	jal rotate_clkws_90
	move $t9, $a0	#move rotated buffer into t9
	move $a0, $a1	#move output.txt into $a0 to run initialize
	move $a1, $t9
	jal initialize
	move $t9, $a0	#move filename into t9
	move $a0, $a1	#move buffer into $a0 to run rotate90 again
	move $a1, $t9
	jal rotate_clkws_90
	move $t9, $a0	#move filename into t9
	move $a0, $a1	#move buffer into $a0 to run rotate90 again
	move $a1, $t9
	jal initialize
	move $t9, $a0	#move filename into t9
	move $a0, $a1	#move buffer into $a0 to run rotate90 again
	move $a1, $t9
	jal rotate_clkws_90
	j part5_exit

part5_exit:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	move $a0, $s1	#move s1 original buffer back into a1 
	move $a1, $s4	#move out.txt back into a0
 	jr $ra

################################## PART 6 ###########################
.globl mirror
mirror:
li $s1, 0
	li $s2, 0
	li $s3, 0
	li $s4, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	li $t8, 0
	li $t9, 0
	addi $sp, $sp, -352 # allocate space on stack	(9*9)= 81 +2= 83 *4(because storing integers)= 332, + 20 = 352 
	sw $ra, 0($sp)
	sw $s1, 4($sp)	#save s1 onto stack
	sw $s2, 8($sp)	# s2 will be used to store number of rows
	sw $s3, 12($sp)	# s3 will be used to store number of columns
	sw $s4, 16($sp)
	move $s1, $a0	# a0 contains address to buffer, move into $s1
	move $s4, $a1	# a1 has filename (output.txt)

	addi $t2, $sp, 20   # beginning of an array that will hold the rotated buffer
	move $t9, $t2		# t9 will hold starting point of t2(the rotated array)
	move $t8, $t2		# also starting point of t2, need this to swap row and col in output.txt
	move $a1, $s1

mirror_get_row_and_column:
	lw $t1, 0($a0)		# load row from buffer(a1) into t1
	move $s2, $t1		#move # of rows into s2
	sw $t1, 0($t2)		#store # of row to t2(beginning of array)  
	addi $t2, $t2, 4
	addi $a0, $a0, 4
	
	lw $t1, 0($a0)		# load column from buffer(a1) into t1
	move $s3, $t1		#move # of columns into s3
	sw $t1, 0($t2)		#store # of columns to t2(beginning of array)
	addi $t2, $t2, 4
	addi $a0, $a0, 4
	li $t4, 0
	move $t1, $s2  		# move # of rows back into t1 for counter loop
	
mirror_loop:
	 beq $t4, $t1, part6_end_loop		# t4 is rows counter, done with entire matrix when t4 = # of rows
	 move $t3, $s3	# set t3 to # of column, used for column counter
	addi $t3, $t3, -1  #since index i and j both start at 0 	
	 
mirror_col_loop:
	blt $t3, $0, mirror_row_increment	# t3(column) less than 0, done with the column, move to next row
	mul $t5, $t4, $s3	#t5 = i(t4 = # of rows, start at 0) * (s3)# of columns
	add $t5, $t5, $t3	#t5 = (i(row) * (s3)# of columns + j(column t3))
	sll $t5, $t5, 2		# mulitply by elements in bytes (4 b/c intger)
	add $t6, $a0, $t5	# t7 = base addr + $t6  
	lw $t7, 0($t6)		#(the desired element)
	sw $t7, 0($t2)	
	addi $t2, $t2, 4	# move to next integer slot 
	addi $t3, $t3, -1
	j mirror_col_loop

mirror_row_increment:
	addi $t4, $t4, 1		#t4 contains column counter
	j mirror_loop
	
part6_end_loop:
	move $a1, $t9	#move t9 (points to start of rotated buffer buffer) back into a1 for write_file	
	move $a0, $s4	#move out.txt back into a0 for write_file	
	jal write_file		#a0 has output.txt, a1 has buffer, good to jal write_file
	j part6_exit
		
part6_exit:
	move $a0, $t9	#move beginning of rotated t9 back into a0
	move $a1, $s4	#move out.txt back into a0
	lw $ra, 0($sp)
	lw $s1, 4($sp)	#reload s1 original value back into s1
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	addi $sp, $sp, 352 #deallocate stack 
 	jr $ra


################################## PART 7 ###########################
.globl duplicate
duplicate:
	li $s1, 0
	li $s2, 0
	li $s3, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	li $t8, 0
	li $t9, 0
	addi $sp, $sp, -348 # allocate space on stack	(9*9)= 81 +2= 83 *4(because storing integers)= 332, + 16 = 348 
	sw $ra, 0($sp)
	sw $s1, 4($sp)	#save s1 onto stack
	sw $s2, 8($sp)
	sw $s3, 12($sp)	#store number of rows
	move $s1, $a0	# a1 contains address to buffer, move into $s1]
	
	li $t2, 0
	addi $t2, $sp, 16   # will hold all decimal values of each row, an array
	move $a0, $s1
	li $t0, 0
	li $t1, 0   	#will hold an entire row
	move $t3, $t2	# contains pointer to beginning of array
	move $s2, $t2	# will reset t3 each time using s2
	li $t4, 0
	li $t6, 0
	li $t7, 0 
	li $v0, -1   #assume no duplicate to begin with, change to 1 if duplicate exist
	li $v1, 0 	#assume no duplicate to begin with, 
	
duplicate_skip_row_and_col:
	lw $t8, 0($a0)		#contains copy of # of row
	lw $s3, 0($a0)		#s3 also contains row
	addi $a0, $a0, 4
	lw $t9, 0($a0)		#contains column, t9 stays orignal
	addi $a0, $a0, 4	#start at third, first two is row and column
	move $t7, $t9		#copy # of columns into t7
	move $t6, $t9
	addi $t6, $t6, -1   # power of 2, MSB should be 2^(#ofcolumns - 1)
	
duplicate_loop:
	beq $t7, $0, duplicate_next_row
	beq $t8, $0, duplicate_done	#contains copy of # of row
	lb $t0, 0($a0)
	sllv $t0, $t0, $t6
	add $t1, $t1, $t0  	#t1 will hold the final decimal value of a row
	addi $a0, $a0, 4
	addi $t7, $t7, -1 	#copy of # of columns
	addi $t6, $t6, -1 	# orignally contained t7-1, for pwoer of 2 calculations
	j duplicate_loop
	
duplicate_next_row:
	beq $t8, $0, duplicate_done
	sw $t1, 0($t2)
	addi $t2, $t2, 4  #go to next row
	move $t7, $t9		#copy # of columns into t7
	move $t6, $t9	#reinitialize
	addi $t6, $t6, -1
	addi $t8, $t8, -1	# when rows reaches 0, then done with all rows
	li $t1, 0	#reset t1
	j duplicate_loop	

duplicate_done:
	li $t0, 1
	li $t1, 0 
	li $t7, 9	#t7 resetted for further use	
duplicate_initialize:
	beq $s3, $0, part7_exit	#done, no duplicate found
	addi $s3, $s3, -1	#start at next row of whatever row we're at
	move $t8, $s3   #move original # of rows in s3 into t8
	lw $t5, 0($s2) 	#load first integer in the array to check with each row
	move $t1, $t0
	addi $t0, $t0, 1
	addi $s2, $s2, 4
	move $t3, $s2
	addi $t1, $t1, 1
	j duplicate_test_equality_loop
	
duplicate_test_equality_loop:
	beq $t8, $0, duplicate_initialize
	lw $t4, 0($t3)
	beq $t5, $t4, duplicate_confirm
	addi $t3, $t3, 4
	addi $t1, $t1, 1	#each time i increment t3, t1++
	addi $t8, $t8, -1
	j duplicate_test_equality_loop
	
duplicate_confirm:
	li $v0, 1	# return 1 in v0
	blt $t1, $t7, duplicate_change_duplicate
	j duplicate_initialize	#if come here, it means previous step did not execute, (added this line fixed dup3p.txt)
	
duplicate_change_duplicate:
	move $t7, $t1
	move $v1, $t1	#t1 will contain the index
	j duplicate_initialize
	
part7_exit: 
	move $a0, $t2
	lw $ra, 0($sp)
	lw $s1, 4($sp)	#reload s1 original value back into s1
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 348 #deallocate stack 
 	jr $ra
