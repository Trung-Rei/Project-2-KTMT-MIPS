.data
array: .space 400  #Mang co 100 phan tu

nhap: .asciiz "Nhap So Luong Phan Tu: "
nhap2: .asciiz "Nhap Phan Tu: "
space: .asciiz " "
mangla: .asciiz "Mang vua nhap la: "

tongla: .asciiz "Tong la: "

nguyento: .asciiz "Cac so nguyen to la: "

maxla: .asciiz "So lon nhat la: "

nhapx: .asciiz "Nhap so x: "
false: .asciiz "Khong co so do trong mang"
true: .asciiz "So do co trong mang, vi tri index = "

# Menu
menu1: .asciiz "1. Xuat ra cac phan tu\n"
menu2: .asciiz "2. Tinh tong cac phan tu\n"
menu3: .asciiz "3. Liet ke cac phan tu la so nguyen to\n"
menu4: .asciiz "4. Tim max\n"
menu5: .asciiz "5. Tim phan tu co gia tri x nguoi dung nhap vao\n"
menu6: .asciiz "6. Thoat chuong trinh\n"
option: .asciiz "\nNhap su lua chon cua ban: "

.text
.globl main


main: 

jal inputSizeOfArr
jal inputArr
jal menu
b done

# hien thi menu
menu:
	move $t5, $ra

	li $v0, 4
	la $a0, menu1
	syscall
	li $v0, 4
	la $a0, menu2
	syscall
	li $v0, 4
	la $a0, menu3
	syscall
	li $v0, 4
	la $a0, menu4
	syscall
	li $v0, 4
	la $a0, menu5
	syscall
	li $v0, 4
	la $a0, menu6
	syscall
	b loopMenu
loopMenu: 
	li $v0, 4
	la $a0, option
	syscall
	li $v0, 5
	syscall

	li $t6, 1
	beq $v0, $t6, outputArr

	li $t6, 2
	beq $v0, $t6, Sum

	li $t6, 3
	beq $v0, $t6, Prime

	li $t6, 4
	beq $v0, $t6, Max

	li $t6, 5
	beq $v0, $t6, findX

	li $t6, 6
	beq $v0, $t6, exitMenu

	j loopMenu
exitMenu:
	move $ra, $t5
	jr $ra
	
# ham nhap so luong phan tu
inputSizeOfArr:
	li $v0, 4
	la $a0, nhap
	syscall
	li $v0, 5
	syscall
	bgt $v0, 100, inputSizeOfArr
	blt $v0, 0, inputSizeOfArr
	move $s0, $v0
	li $t7, 4 #size of int
	mul $s0, $s0, $t7
	jr $ra

# ham nhap mang
inputArr:
	li $t0, 0 #index
	b loopInputArr
loopInputArr:
	beq $t0, $s0, exitInputArr
	li $v0, 4
	la $a0, nhap2
	syscall
	li $v0, 5
	syscall
	sw $v0, array($t0)
	addi $t0, $t0, 4
	j loopInputArr
exitInputArr:
	jr $ra

# ham xuat mang
outputArr:
	li $v0, 4
	la $a0, mangla
	syscall
	li $t0, 0 # index
	b loopOutputArr
loopOutputArr:
	beq $t0, $s0, exitOutputArr
	li $v0, 1
	lw $a0, array($t0)
	syscall
	li $v0, 4
	la $a0, space
	syscall
	addi $t0, $t0, 4
	j loopOutputArr
exitOutputArr:
	#jr $ra
	j loopMenu

# ham tinh tong 
Sum:
	li $t0, 0 #index
	li $s1, 0 #sum
	b loopSum
loopSum:
	beq $t0, $s0, exitSum
	lw $t1, array($t0)
	add $s1, $s1, $t1
	addi $t0, $t0, 4
	j loopSum
exitSum:
	li $v0, 4
	la $a0, tongla
	syscall
	li $v0, 1
	move $a0, $s1
	syscall
	#jr $ra
	j loopMenu

# kiem tra co phai so nguyen to
checkPrime:
	li $t2, 2 #index
 	b loopCheckPrime
loopCheckPrime:
	bge $t2, $t1, exitLoopCheckPrime
	rem $t7 $t1, $t2 #$t7 is remainder
	beq $t7, $zero, exitLoopCheckPrime
	addi $t2, $t2, 1
	j loopCheckPrime
exitLoopCheckPrime:
	beq $t2, $t1, temp
	li $t3, 0
	jr $ra
temp: 
	li $t3, 1
	jr $ra


#Xuat cac so nguyen to
Prime:
	li $v0, 4
	la $a0, nguyento
	syscall
	li $t0, 0 #index
	li $t3, 0 #flag of checkPrime. 0 is false, 1 is true
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	b loopPrime
loopPrime:
	beq $t0, $s0, exitPrime
	lw $t1, array($t0)
	addi $t0, $t0, 4
	jal checkPrime
	beq $t3, $zero, loopPrime
	li $v0, 1
	move $a0, $t1
	syscall
	li $v0, 4
	la $a0, space
	syscall
	j loopPrime
	
exitPrime:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	#jr $ra
	j loopMenu

Max:
	li $t0, 4 #index
	lw $s1, array($zero) #gia tri max
	b loopMax
loopMax:
	beq $t0, $s0, exitMax
	lw $t1, array($t0)
	bgt $t1, $s1, assignMax
	addi $t0, $t0, 4
	j loopMax
assignMax:
	move $s1, $t1
	addi $t0, $t0, 4
	j loopMax
exitMax:
	li $v0, 4
	la $a0, maxla
	syscall
	li $v0, 1
	move $a0, $s1
	syscall
	#jr $ra
	j loopMenu

#Tim phan tu gia tri x
findX:
	li $t0, 0 #index
	li $v0, 4
	la $a0, nhapx
	syscall
	li $v0, 5
	syscall
	move $s1, $v0 #s1 la gia tri x
	b loopFindX
loopFindX:
	beq $t0, $s0, exitFindX
	lw $t1, array($t0) 
	beq $s1, $t1, exitFindX
	addi $t0, $t0, 4
	j loopFindX
exitFindX:
	beq $t0, $s0, notInclude
	li $v0, 4
	la $a0, true
	syscall
	li $t7, 4
	div $t0, $t0, $t7

	li $v0, 1
	move $a0, $t0
	syscall
	#jr $ra
	j loopMenu
notInclude:
	li $v0, 4
	la $a0, false
	syscall
	#jr $ra
	j loopMenu
done:



