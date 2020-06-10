.data
fin: .asciiz "input_sort.txt"
fout: .asciiz "output_sort.txt"
buffer: .space 1024
.text
.globl main
main:
	###############################################################
	# Open (for writing) a file that does not exist
	li   $v0, 13       # system call for open file
	la   $a0, fin      # output file name
	li   $a1, 0        # Open for writing (flags are 0: read, 1: write)
	li   $a2, 0        # mode is ignored
	syscall            # open a file (file descriptor returned in $v0)
	move $s6, $v0      # save the file descriptor 
	
	#read from file
	li   $v0, 14       # system call for read from file
	move $a0, $s6      # file descriptor 
	la   $a1, buffer   # address of buffer to which to read
	li   $a2, 1024     # hardcoded buffer length
	syscall            # read from file

	# Close the file 
	li   $v0, 16       # system call for close file
	move $a0, $s6      # file descriptor to close
	syscall            # close file


	#Array = $s0
	#partition(low = $a0, high = $a1) -------pivot = $t0
	#return left in $v0
	partitionFunc:
		#pivot = a[high]
		sll $t1, $a1, 2		#t1 = high * size of(int)
		addu $t1, $t1, $s0	#t1 = &arr[high]
		lw $t0, 0($t1)		#t0 = arr[high]
		#left ($t1) = low
		move $t1, $a0
		#right ($t2) = high - 1
		subi $t2, $a1, 1

	whileTrue:

		leftCondition1:
			ble $t1, $t2, leftCondition2	#left <= right
			j rightCondition1
			leftCondition2:
			sll $t3, $t1, 2
			add $t3, $t3, $s0
			lw $t3, 0($t3)		#arr[left]
			blt $t3, $t0, leftIncr
			j rightCondition1
			leftIncr:	#left++
			addi $t1, $t1, 1
			j leftCondition1

		rightCondition1:
			bge $t2, $t1, rightCondition2
			j nextCommand
			rightCondition2:
			sll $t3, $t2, 2
			add $t3, $t3, $s0
			lw $t3, 0($t3)		#arr[right]
			bgt $t3, $t0, rightDecr		#arr[right] > pivot
			j nextCommand
			rightDecr:
			subi $t2, $t2, 1
			j rightCondition1

		nextCommand:
			bge $t1, $t2, leftGreaterThanRight
			# store arr[left] in $a2; arr[right] in $a3
			sll $t3, $t1, 2
			add $t3, $t3, $s0
			lw $a2, 0($t3)
			sll $t3, $t2, 2
			add $t3, $t3, $s0
			lw $a3, 0($t3)
			jal swap
			#left++
			addi $t1, $t1, 1
			#right--
			$subi $t2, $t2, 1
			j whileTrue

		leftGreaterThanRight:
			# store arr[left] in $a2; arr[high] in $a3
			sll $t3, $t1, 2
			add $t3, $t3, $s0
			lw $a2, 0($t3)
			sll $t3, $a1, 2
			add $t3, $t3, $s0
			lw $a3, 0($t3)
			jal swap
			#return left
			move $v0, $t1
			jr $ra

	swap: #swap($a2, $a3)
		move $t9, $a2
		move $a2, $a3
		move $a3, $t9
		jr $ra

	#Array = $s0
	#quickSort(low = $t5, high = $t6)
	quickSort:
		blt $t5, $t6, quickSort_ifTrue
		j quickSort_ifFalse
		quickSort_ifTrue:
			jal partitionFunc
			# pi = partitionFunc(low, high); pi = $t0
			move $t0, $v0
			# quickSort(low, pi - 1)
			subi $t6, $t0, 1
			jal quickSort
			# quickSort(pi + 1, high)
			addi $t5, $t0, 1
			jal quickSort
		quickSort_ifFalse:
			jr $ra



