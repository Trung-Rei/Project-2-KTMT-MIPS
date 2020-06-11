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
