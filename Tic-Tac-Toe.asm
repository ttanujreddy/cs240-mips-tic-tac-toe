.data
    board:         .word 0,0,0, 0,0,0, 0,0,0
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
        addi $t1, $zero, 9
        la $t0, board

    init_loop:
        beq $t1, $zero, main_loop
        sw $zero, 0($t0)
        addi $t0, $t0, 4
        addi $t1, $t1, -1
        j init_loop

    main_loop:
        jal drawBoard
        
        jal readMove
        
        # Compute index = row*3 + col
        mul $t6, $v0, 3
        add $t6, $t6, $v1
        sll $t6, $t6, 2
        la $t7, board
        add $t7, $t7, $t6
        lw $t8, 0($t7)
        bne $t8, $zero, bad_move
        lw $t9, currentPlayer
        sw $t9, 0($t7)
        
        jal switchPlayer
        j main_loop

    bad_move:
        li $v0, 4
        la $a0, invalidMove
        syscall
        
        j main_loop

    drawBoard:
        addi $sp, $sp, -8
        sw $ra, 4($sp)
        addi $t1, $zero, 0
        la $t0, board
    draw_row:
        addi $t2, $zero, 0
    draw_col:
        mul $t3, $t1, 3
        add $t3, $t3, $t2
        sll $t3, $t3, 2
        add $t3, $t3, $t0
        lw $t4, 0($t3)
        beq $t4, $zero, printE
        addi $t5, $zero, 1
        beq $t4, $t5, printX
        j printO
    printE:
        li $v0, 4
        la $a0, charE
        syscall
        
        j cont
    printX:
        li $v0, 4
        la $a0, charX
        syscall
        
        j cont
    printO:
        li $v0, 4
        la $a0, charO
        syscall
    cont:
        addi $t2, $t2, 1
        blt $t2, 3, draw_col
        
        li $v0, 4
        la $a0, newline
        syscall
        
        addi $t1, $t1, 1
        blt $t1, 3, draw_row

        lw $ra, 4($sp)
        addi $sp, $sp, 8
        jr $ra

    readMove:
        addi $sp, $sp, -8
        sw $ra, 4($sp)
    promptRow:
        li $v0, 4
        la $a0, rowPrompt
        syscall
        
        li $v0, 5
        syscall
        
        move $t0, $v0
        blt $t0, $zero, promptRow
        bgt $t0, 2, promptRow
    promptCol:
        li $v0, 4
        la $a0, colPrompt
        syscall
        
        li $v0, 5
        syscall
        
        move $t1, $v0
        blt $t1, $zero, promptCol
        bgt $t1, 2, promptCol

        move $v0, $t0      # row
        move $v1, $t1      # col

        lw $ra, 4($sp)
        addi $sp, $sp, 8
        jr $ra

    switchPlayer:
        lw $t0, currentPlayer
        addi $t1, $zero, 1
        beq $t0, $t1, setO
        sw $t1, currentPlayer
        j end_switch

    setO:
        addi $t1, $zero, 2
        sw $t1, currentPlayer

    end_switch:
        jr $ra
