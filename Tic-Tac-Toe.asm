.data
	board:         .word 0,0,0, 0,0,0, 0,0,0    # 3×3 grid
	currentPlayer: .word 1

	rowPrompt:   .asciiz "Enter row (0-2): "
	colPrompt:   .asciiz "Enter col (0-2): "
	invalidMove: .asciiz "Invalid move! Try again.\n"
	newline:     .asciiz "\n"
	charX:       .asciiz "X "
	charO:       .asciiz "O "
	charE:       .asciiz "_ "
	winXMsg:     .asciiz "Player X wins!\n"
	winOMsg:     .asciiz "Player O wins!\n"
	drawMsg:     .asciiz "It's a draw!\n"

.text
.globl main
	main:
	# Initialize board to zeros
    la $t0, board
    li $t1, 9

	init_loop:
    	beq $t1, $zero, main_loop
  		sw $zero, 0($t0)
    	addi $t0, $t0, 4
    	addi $t1, $t1, -1
    	j init_loop

	main_loop:
    	# Render the board
    	jal drawBoard
    	li $v0, 10
    	syscall
    
    # drawBoard: print 3×3 grid
	drawBoard:
    	addi $sp, $sp, -8
    	sw $ra, 4($sp)
    	la $t0, board
    	li $t1, 0            # row index

	draw_row:
    	li $t2, 0            # col index

	draw_col:
    	mul $t3, $t1, 3
    	add $t3, $t3, $t2
	    sll $t3, $t3, 2
    	add $t3, $t3, $t0
    	lw $t4, 0($t3)
	    beq $t4, $zero, printE
    	li $t5, 1
	    beq $t4, $t5, printX
    	j printO

	printE:
	    la $a0, charE
    	li $v0, 4
	    syscall
    	j cont

	printX:
	    la $a0, charX
    	li $v0, 4
	    syscall
    	j cont

	printO:
    	la $a0, charO
	    li $v0, 4
    	syscall

	cont:
	    addi $t2, $t2, 1
    	blt $t2, 3, draw_col
	    la $a0, newline
    	li $v0, 4
	    syscall
    	addi $t1, $t1, 1
	    blt $t1, 3, draw_row

	    lw $ra, 4($sp)
    	addi $sp, $sp, 8
	    jr $ra
