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
        addi $t1, $zero, 9    # setup counter
        la $t0, board

    init_loop:
        beq $t1, $zero, main_loop    # all cells cleared?
        sw $zero, 0($t0)    # clear cell
        addi $t0, $t0, 4    # next cell
        addi $t1, $t1, -1   # decrement
        j init_loop

    main_loop:
        jal drawBoard    # display
        
        jal readMove     # input
        
        # idx=row*3+col
        mul $t6, $v0, 3
        add $t6, $t6, $v1
        sll $t6, $t6, 2
        la $t7, board
        add $t7, $t7, $t6
        lw $t8, 0($t7)
        bne $t8, $zero, bad_move
        lw $t9, currentPlayer
        sw $t9, 0($t7)			# place
        
        jal checkGameOver    	# win/draw
        
        jal switchPlayer     	# toggle
        
        j main_loop

    bad_move:
        li $v0, 4
        la $a0, invalidMove  	# error
        syscall
        
        j main_loop

    drawBoard:
        addi $sp, $sp, -8
        sw $ra, 4($sp)
        addi $t1, $zero,0    	# row
        la $t0, board
    draw_row:
        addi $t2, $zero, 0    	# col
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
        la $a0, charE    # '_'
        syscall
        
        j cont
    printX:
        li $v0, 4
        la $a0, charX    # 'X'
        syscall
        
        j cont
    printO:
        li $v0, 4
        la $a0, charO    # 'O'
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
        la $a0, rowPrompt    	# ask
        syscall
        
        li $v0,5
        syscall
        
        move $t0, $v0   		# row
        blt $t0, $zero, promptRow
        bgt $t0, 2, promptRow
    promptCol:
        li $v0, 4
        la $a0, colPrompt    	# ask
        syscall
        
        li $v0, 5
        syscall
        
        move $t1, $v0   # col
        blt $t1, $zero, promptCol
        bgt $t1, 2, promptCol
        move $v0, $t0   # ret row
        move $v1, $t1   # ret col
        lw $ra, 4($sp)
        addi $sp, $sp, 8
        jr $ra

    switchPlayer:
        lw $t0, currentPlayer
        addi $t1, $zero, 1    # if1->2
        beq $t0, $t1, setO
        sw $t1, currentPlayer
        j end_switch
    setO:
        addi $t1, $zero, 2
        sw $t1, currentPlayer
    end_switch:
        jr $ra

    checkGameOver:    # check win/draw
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        la $t0, board
        # rows
        addi $t1, $zero, 0
    row_loop:
        mul $t5, $t1, 3
        sll $t5, $t5, 2
        add $t5, $t0, $t5
        lw $t2, 0($t5)
        beq $t2, $zero, skip_row
        lw $t3, 4($t5)
        lw $t4, 8($t5)
        bne $t2, $t3, skip_row
        bne $t2, $t4, skip_row
        move $t6, $t2
        j print_win
    skip_row:
        addi $t1, $t1, 1
        blt $t1, 3, row_loop
        # cols
        addi $t1, $zero, 0
    col_loop:
        sll $t7, $t1, 2
        add $t8, $t0, $t7
        lw $t2, 0($t8)
        beq $t2, $zero, skip_col
        addi $t8, $t8, 12
        lw $t3, 0($t8)
        addi $t8, $t8, 12
        lw $t4, 0($t8)
        bne $t2, $t3, skip_col
        bne $t2, $t4, skip_col
        move $t6, $t2
        j print_win
    skip_col:
        addi $t1, $t1, 1
        blt $t1, 3, col_loop
        # diag1
        lw $t2, 0($t0)
        beq $t2, $zero, skip_d1
        lw $t3, 16($t0)
        lw $t4, 32($t0)
        bne $t2, $t3, skip_d1
        bne $t2, $t4, skip_d1
        move $t6, $t2
        j print_win
    skip_d1:
        # diag2
        lw $t2, 8($t0)
        beq $t2, $zero ,skip_d2
        lw $t3, 16($t0)
        lw $t4, 24($t0)
        bne $t2, $t3, skip_d2
        bne $t2, $t4, skip_d2
        move $t6, $t2
        j print_win
    skip_d2:
        # draw?
        addi $t1, $zero, 0
        addi $t9, $zero, 0
    draw_loop:
        lw $t2, 0($t0)
        beq $t2, $zero, inc_empty
        j next_cell
    inc_empty:
        addi $t9, $t9, 1
    next_cell:
        addi $t0, $t0, 4
        addi $t1, $t1, 1
        blt $t1, 9, draw_loop
        beq $t9, $zero, no_exit
        j no_exit
        # draw
        li $v0, 4
        la $a0, drawMsg
        syscall
        
        li $v0, 10
        syscall
    no_exit:
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra
    print_win:    # t6 = 1 or 2
        li $v0, 4
        addi $t7, $zero, 1
        beq $t6, $t7, isX
        la $a0, winOMsg
        j exit_game
    isX:
        la $a0, winXMsg
    exit_game:
        syscall
        li $v0, 10
        syscall
