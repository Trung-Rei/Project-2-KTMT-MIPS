.data
fin: .asciiz "input_sort.txt"
fout: .asciiz "output_sort.txt"
arr: .word 4 20 50 35 18 67
.text
.globl main
main:
	la $s0, arr
	li $a0, 0	#low = 0
	li $a1, 5	#high = n - 1
	jal quickSort
	li $t0, 0	#i = 0
loop1:
	bge     $t0, 6, exit

	# load word from addrs and goes to the next addrs
	lw      $t2, 0($s0)
	addi    $s0, $s0, 4

	# syscall to print value
	li      $v0, 1      
	move    $a0, $t2
	syscall
	# optional - syscall number for printing character (space)
	li      $a0, 32
	li      $v0, 11  
	syscall

	#increment counter
	addi    $t0, $t0, 1
	j      loop1

exit:
	li $v0, 10
	syscall



#Array = $s0
#partition(low = $a0, high = $a1)
#return left in $v0
partitionFunc:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	sll $t1, $a1, 2		#t1 = high * size of(int)
	addu $t1, $t1, $s0	#t1 = &arr[high]
	lw $t0, 0($t1)		#t0 = arr[high] = pivot
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
		blt $t3, $t0, leftIncr #arr[left] < pivot
		j rightCondition1
		leftIncr:	#left++
			addi $t1, $t1, 1
			j leftCondition1

	rightCondition1:
		bge $t2, $t1, rightCondition2	#right >= left
		j nextCommand
	rightCondition2:
		sll $t3, $t2, 2
		add $t3, $t3, $s0
		lw $t3, 0($t3)		#arr[right]
		bgt $t3, $t0, rightDecr		#arr[right] > pivot
		j nextCommand
		rightDecr:	#right--
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
		# update in $s0
		sll $t3, $t1, 2
		add $t3, $t3, $s0
		sw $a2, 0($t3)
		sll $t3, $t2, 2
		add $t3, $t3, $s0
		sw $a3, 0($t3)
		#left++
		addi $t1, $t1, 1
		#right--
		subi $t2, $t2, 1
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
		# update in $s0
		sll $t3, $t1, 2
		add $t3, $t3, $s0
		sw $a2, 0($t3)
		sll $t3, $a1, 2
		add $t3, $t3, $s0
		sw $a3, 0($t3)
		#return left
		move $v0, $t1
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra

swap: #swap($a2, $a3)
	move $t9, $a2
	move $a2, $a3
	move $a3, $t9
	jr $ra

#Array = $s0
#quickSort(low = $a0, high = $a1)
quickSort:
	addi $sp, $sp, -12
	# store arg in stack
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	blt $a0, $a1, quickSort_ifTrue
	j quickSort_end
	quickSort_ifTrue:
		jal partitionFunc
		# pi = partitionFunc(low = a0, high = a1); pi = $t0
		move $t0, $v0
		# quickSort(low, pi - 1)
		subi $a1, $t0, 1
		jal quickSort
		# quickSort(pi + 1, high)
		addi $a0, $t0, 1
		jal quickSort
	quickSort_end:
		lw $ra, 0($sp)
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		addi $sp, $sp, 12
		jr $ra



