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
    	# TODO: initialize board
    	# TODO: game loop
	    li $v0, 10
    	syscall