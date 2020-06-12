.data

	f.buffer: .space 16384 # luu du lieu cua file
	f.curr: .word 0 # vi tri con tro trong buffer
	f.inPath: .asciiz "D:\\game\\hao\\eng\\ktmt\\proj2\\repo\\Project-2-KTMT-MIPS\\input_sort.txt"
	f.outPath: .asciiz "D:\\game\\hao\\eng\\ktmt\\proj2\\repo\\Project-2-KTMT-MIPS\\output_sort.txt"
	f: .word 0 # file decriptor

	arr: .word 0:1000 # mang int
	n: .word 0 # N

.text
.globl main

main:

	# doc mang arr
	jal readArray

	# sort here
    la $s0, arr
	li $a0, 0	#low = 0
	lw $a1, n	#high = n - 1
    sub $a1, $a1, 1
	jal quickSort

	# luu mang arr
	jal writeArray

	li $v0, 10
	syscall

# luu du lieu vao buffer: begin
fileToBuffer:

	# mo file
	li $v0, 13
	la $a0, f.inPath
	la $a1, 0
	syscall
	sw $v0, f

	# doc file vao buffer
	li $v0, 14
	lw $a0, f
	la $a1, f.buffer
	la $a2, 16384
	syscall

	# dong file
	li $v0, 16
	lw $a0, f
	syscall

	jr $ra
# luu du lieu vao buffer: end

# doc 1 so integer tu buffer vao vung nho co dia chi $a0: begin
getInt:
	
	# loai bo cac ki tu khong phai so
	getInt.loop1:

		# lay chu so o dau buffer
		lw $t0, f.curr 
		lb $t1, f.buffer($t0)

		# dieu kien dung
		bgt $t1, '9', getInt.loop1.conti1
		blt $t1, '0', getInt.loop1.conti1
		j getInt.endLoop1
		getInt.loop1.conti1:

		# tang curr len 1
		add $t0, $t0, 1
		sw $t0, f.curr

		j getInt.loop1
	getInt.endLoop1:

	# $v0 chua ket qua
	li $v0, 0 

	# doc tung chu so
	getInt.loop2:

		# lay chu so o dau buffer
		lw $t0, f.curr 
		lb $t1, f.buffer($t0)

		# dieu kien dung
		bgt $t1, '9', getInt.endLoop2 
		blt $t1, '0', getInt.endLoop2

		# them vao $v0
		sub $t1, $t1, '0'
		li $t2, 10
		multu $v0, $t2
		mflo $v0
		addu $v0, $v0, $t1

		# tang con tro len 1
		add $t0, $t0, 1
		sw $t0, f.curr

		j getInt.loop2
	getInt.endLoop2:

	# luu vao vung nho co dia chi $a0
	sw $v0, ($a0)

	jr $ra
# doc 1 so integer tu buffer vao vung nho co dia chi $a0: end

# doc mang tu file: begin
readArray:
	
	# doc vao buffer
	add $sp, $sp, -4
	sw $ra, ($sp)
	jal fileToBuffer
	lw $ra, ($sp)
	add $sp, $sp, 4
	
	# doc N
	la $a0, n
	add $sp, $sp, -4
	sw $ra, ($sp)
	jal getInt
	lw $ra, ($sp)
	add $sp, $sp, 4
	
	li $t3, 0 # bien dem
	lw $t4, n # N
	la $t5, arr # arr
	
	# doc mang
	readArr.loop:

		# dieu kien dung
		bge $t3, $t4, readArr.endLoop

		# lay dia chi arr[i]
		li $t6, 4
		mult $t3, $t6
		mflo $a0
		add $a0, $a0, $t5

		# doc arr[i]
		add $sp, $sp, -16
		sw $ra, ($sp)
		sw $t3, 4 ($sp)
		sw $t4, 8 ($sp)
		sw $t5, 12 ($sp)
		jal getInt
		lw $ra, ($sp)
		lw $t3, 4 ($sp)
		lw $t4, 8 ($sp)
		lw $t5, 12 ($sp)
		add $sp, $sp, 16

		# tang bien dem len 1
		add $t3, $t3, 1

		j readArr.loop
	readArr.endLoop:
	
	jr $ra
# doc mang tu file: end

# luu du lieu vao file: begin
bufferToFile:

	# mo file
	li $v0, 13
	la $a0, f.outPath
	la $a1, 1
	syscall
	sw $v0, f

	# ghi du lieu tu buffer vao file
	li $v0, 15
	lw $a0, f
	la $a1, f.buffer
	lw $a2, f.curr
	syscall

	# dong file
	li $v0, 16
	lw $a0, f
	syscall

	jr $ra
# luu du lieu vao file: end

# day 1 so nguyen tai vung nho co dia chi $a0 vao buffer: begin
pushInt:

	lw $t0, ($a0) # gia tri can day vao buffer
	li $t1, 0 # dem so chu so

	# vong lap de dem so chu so
	pushInt.loop1:

		# chia 10
		divu $t0, $t0, 10
		add $t1, $t1, 1 # tang bien dem

		# dieu kien dung
		beq $t0, 0, pushInt.endLoop1
		
		j pushInt.loop1
	pushInt.endLoop1:

	lw $t0, ($a0) # gia tri can day vao buffer
	lw $t2, f.curr # $t2 luu vi tri con tro
	add $t2, $t2, $t1
	add $t2, $t2, -1 # t2 = t2 + t1 - 1 (vi tri chu so hang don vi)

	# ghi lan luot tung chu so vao buffer tu phai sang trai
	pushInt.loop2:

		# dieu kien dung
		lw $t3, f.curr
		blt $t2, $t3, pushInt.endLoop2

		# ghi chu so vao buffer[t2]
		li $t3, 10
		divu $t0, $t3
		mfhi $t3
		add $t3, $t3, '0'
		sb $t3, f.buffer($t2)
		divu $t0, $t0, 10 # chia 10

		add $t2, $t2, -1 # giam bien dem

		j pushInt.loop2
	pushInt.endLoop2:

	# curr = curr + t1
	lw $t3, f.curr
	add $t3, $t3, $t1
	# them khoang trang
	li $t2, ' '
	sb $t2, f.buffer($t3)
	add $t3, $t3, 1
	sw $t3, f.curr

	jr $ra
# day 1 so nguyen tai vung nho co dia chi $a0 vao buffer: end

# ghi mang ra file: begin
writeArray:
	
	sw $zero, f.curr # reset curr = 0

	li $t0, 0 # bien dem
	lw $t1, n # N
	la $t2, arr # arr
	
	# ghi mang
	writeArr.loop:

		# dieu kien dung
		bge $t0, $t1, writeArr.endLoop

		# lay dia chi arr[i]
		li $t3, 4
		mult $t0, $t3
		mflo $a0
		add $a0, $a0, $t2

		# ghi arr[i]
		add $sp, $sp, -16
		sw $ra, ($sp)
		sw $t0, 4 ($sp)
		sw $t1, 8 ($sp)
		sw $t2, 12 ($sp)
		jal pushInt
		lw $ra, ($sp)
		lw $t0, 4 ($sp)
		lw $t1, 8 ($sp)
		lw $t2, 12 ($sp)
		add $sp, $sp, 16

		# tang bien dem len 1
		add $t0, $t0, 1

		j writeArr.loop
	writeArr.endLoop:
	
	# ghi ra buffer
	add $sp, $sp, -4
	sw $ra, ($sp)
	jal bufferToFile
	lw $ra, ($sp)
	add $sp, $sp, 4
	
	jr $ra
# ghi mang ra file: end

# Code c++ read write buffer
#   
#   char buffer[16384];
#   int curr = 0;
#   
#   int arr[1000];
#   int n;
#   
#   doc mang
#   readint(n);
#   for (int i = 0; i < n; ++i)
#   readint(arr[i]);
#   
#   int readint()
#   {
#   	while (buffer[curr] > 9 || buffer[curr] < 0)
#   		curr = curr + 1;
#   	int num = 0;
#   	while (buffer[curr] <= '9' && buffer[curr] >= '0')
#   	{
#   		num = num * 10 + buffer[curr] - '0';
#   		curr = curr + 1;
#   	}
#   	return num;
#   }
#   
#   curr = 0;
#   
#   ghi mang
#   for (int i = 0; i < n; ++i)
#   writeint(arr[i]);
#
#   void writeint(int a)
#   {
#   	int num = a;
#   	int c = 0;
#   	do {
#   		num /= 10;
#   		++c;
#   	} while (num != 0)
#   	num = a;
#   	int tmp = curr;
#   	for (tmp = tmp + c - 1; tmp >= curr; --tmp)
#   	{
#   		buffer[tmp] = num % 10 + '0';
#   		num /= 10;
#   	}
#   	curr = curr + c;
#   	buffer[curr] = ' ';
#   	++curr;
#   }

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
		addu $t3, $t3, $s0
		lw $t3, 0($t3)		#arr[left]
		bltu $t3, $t0, leftIncr #arr[left] < pivot
		j rightCondition1
		leftIncr:	#left++
			addi $t1, $t1, 1
			j leftCondition1

	rightCondition1:
		bge $t2, $t1, rightCondition2	#right >= left
		j nextCommand
	rightCondition2:
		sll $t3, $t2, 2
		addu $t3, $t3, $s0
		lw $t3, 0($t3)		#arr[right]
		bgtu $t3, $t0, rightDecr		#arr[right] > pivot
		j nextCommand
		rightDecr:	#right--
		subi $t2, $t2, 1
		j rightCondition1

	nextCommand:
		bge $t1, $t2, leftGreaterThanRight
		# store arr[left] in $a2; arr[right] in $a3
		sll $t3, $t1, 2
		addu $t3, $t3, $s0
		lw $a2, 0($t3)
		sll $t3, $t2, 2
		addu $t3, $t3, $s0
		lw $a3, 0($t3)
		jal swap
		# update in $s0
		sll $t3, $t1, 2
		addu $t3, $t3, $s0
		sw $a2, 0($t3)
		sll $t3, $t2, 2
		addu $t3, $t3, $s0
		sw $a3, 0($t3)
		#left++
		addi $t1, $t1, 1
		#right--
		subi $t2, $t2, 1
		j whileTrue

	leftGreaterThanRight:
		# store arr[left] in $a2; arr[high] in $a3
		sll $t3, $t1, 2
		addu $t3, $t3, $s0
		lw $a2, 0($t3)
		sll $t3, $a1, 2
		addu $t3, $t3, $s0
		lw $a3, 0($t3)
		jal swap
		# update in $s0
		sll $t3, $t1, 2
		addu $t3, $t3, $s0
		sw $a2, 0($t3)
		sll $t3, $a1, 2
		addu $t3, $t3, $s0
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
		addi $sp, $sp, -4
		sw $a1, 0($sp)	# store high for left recursive array
		# quickSort(low, pi - 1)
		subi $a1, $t0, 1
		jal quickSort
		lw $a1, 0($sp)
		addi $sp, $sp, 4
		# quickSort(pi + 1, high)
		addi $a0, $t0, 1
		jal quickSort
	quickSort_end:
		lw $ra, 0($sp)
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		addi $sp, $sp, 12
		jr $ra
