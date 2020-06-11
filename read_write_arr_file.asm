.data

	f.buffer: .space 16384 # luu du lieu cua file
	f.curr: .word 0 # vi tri con tro trong buffer
	f.inPath: .asciiz "input_sort.txt"
	f.outPath: .asciiz "output_sort.txt"
	f: .word 0 # file decriptor

	arr: .word 0:1000 # mang int
	n: .word 0 # N

.text
.globl main

main:

	# doc mang arr
	jal readArray

	# sort here


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
		div $t0, $t0, 10
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
		div $t0, $t3
		mfhi $t3
		add $t3, $t3, '0'
		sb $t3, f.buffer($t2)
		div $t0, $t0, 10 # chia 10

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