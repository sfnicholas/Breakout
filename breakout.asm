################ CSC258H1F Fall 2022 Assembly Final Project ##################
# This file contains our implementation of Breakout.
#
# Student 1: Shu Fan Nicholas Au, 1008422002
# Student 2: Future Hu, 1005371704
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    256
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
    .eqv RED 0xff0000
    .eqv GREEN 0x00ff00
    .eqv BLUE 0x0000ff
    .eqv GREY 0x808080
    .eqv WHITE 0xffffff
    .eqv YELLOW 0xffea00
    .eqv BLACK 0x000000
    .eqv TEST_COLOUR 0xf5bc42
    .eqv LIGHTGREEN 0x90EE90
    .eqv PURPLE 0x8A2BE2    
    
    .eqv FRAME_DELAY 3000
    .eqv SLEEP_DELAY 15
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

MY_COLOURS:
	.word	RED  
	.word	GREEN  
	.word	BLUE  
	.word   GREY    
	.word   WHITE  
	.word   YELLOW   
	.word   BLACK  
	.word   LIGHTGREEN
	.word   PURPLE
	
# TODO: can change back the initalization data here.
##############################################################################
# Mutable Data
##############################################################################
DYNAMIC_LOCATION:
    .word   13 	# x_paddle address
    .word   16 	# x_ball location
    .word   28 	# y_ball location
    .word   1	# ball_direction
# The surrounding tiles of the ball
TILE_UP:
	.space 4
TILE_DOWN:
	.space 4	
TILE_LEFT:
	.space 4
TILE_RIGHT:
	.space 4
TILE_UPPER_LEFT:
	.space 4  
TILE_UPPER_RIGHT:
	.space 4
TILE_LOWER_LEFT:
	.space 4  
TILE_LOWER_RIGHT:
	.space 4     
LEVEL:
	.space 4
##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Brick Breaker game.
main:
    # Initialize the game
    # TODO: can add a function to initallize the values
    
# User choose level 1 or 2:
choose_layout_loop:
	li $v0, 32
	li $a0, 1
	syscall
   	lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
   	lw $t8, 0($t0)                  # Load first word from keyboard
   	beq $t8, 1, choose_layout      # If first word 1, key is pressed
   	b choose_layout_loop
   
choose_layout:                     # A key is pressed
      lw $a0, 4($t0)                  # Load second word from keyboard
      beq $a0, 0x32, respond_to_2
      beq $a0, 0x31, respond_to_1
      b choose_layout_loop
   
respond_to_2:
      la $t0, LEVEL
      li $t1, 2
      sw $t1, 0($t0)
      b end_choose_layout
   
respond_to_1:
      la $t0, LEVEL
      li $t1, 1
      sw $t1, 0($t0)
      b end_choose_layout
   
end_choose_layout:
    
# Building the wall
   # Wall: Horizontal Line 
    li $a0, 0
    li $a1, 0
    jal get_location_address

    addi $a0, $v0, 0            # Put return value in $a0
    la $t0, MY_COLOURS
    la $a1, 12($t0)          # colour_address = &MY_COLOURS[3]
    li $a2, 32
    jal draw_hori_line               # Draw grey line
	
  # Wall: Vertical Line 1
    li $a0, 63
    li $a1, 0
    jal get_location_address

    addi $a0, $v0, 0            # Put return value in $a0
    la $t0, MY_COLOURS
    la $a1, 12($t0)          # colour_address = &MY_COLOURS[3]
    li $a2, 32
    jal draw_vert_line               # Draw grey line
    
    # Wall: Vertical Line 2
    li $a0, 0
    li $a1, 0
    jal get_location_address

    addi $a0, $v0, 0            # Put return value in $a0
    la $t0, MY_COLOURS
    la $a1, 12($t0)          # colour_address = &MY_COLOURS[3]
    li $a2, 32
    jal draw_vert_line               # Draw grey line
	
    lw $t0, LEVEL
    beq $t0, 2, level_2
# Draw all the bricks:  FOR LEVEL_1:
    li $a0, 1
    li $a1, 10
    jal get_location_address

    addi $a0, $v0, 0            # Put return value in $a0
    la $t0, MY_COLOURS
    la $a1, 0($t0)          # colour_address = &MY_COLOURS[0]
    li $a2, 30
    jal draw_hori_line               # Draw red line 
    
    li $a0, 1
    li $a1, 11
    jal get_location_address

    addi $a0, $v0, 0            # Put return value in $a0
    la $t0, MY_COLOURS
    la $a1, 4($t0)          # colour_address = &MY_COLOURS[1]
    li $a2, 30
    jal draw_hori_line               # Draw green line 
    
    li $a0, 1
    li $a1, 12
    jal get_location_address

    addi $a0, $v0, 0            # Put return value in $a0
    la $t0, MY_COLOURS
    la $a1, 8($t0)          # colour_address = &MY_COLOURS[2]
    li $a2, 30
    jal draw_hori_line               # Draw blue line 
    b end_level_1
    
# Draw all the bricks: FOR LEVEL_2:
    level_2: 
    li $a0, 1
    li $a1, 12
    jal get_location_address

    addi $a0, $v0, 0            # Put return value in $a0
    la $t0, MY_COLOURS
    la $a1, 0($t0)          # colour_address = &MY_COLOURS[0]
    li $a2, 30
    jal draw_hori_line               # Draw red line 
    
    li $a0, 1
    li $a1, 8
    jal get_location_address

    addi $a0, $v0, 0            # Put return value in $a0
    la $t0, MY_COLOURS
    la $a1, 4($t0)          # colour_address = &MY_COLOURS[1]
    li $a2, 30
    jal draw_hori_line               # Draw green line 
    
    li $a0, 1
    li $a1, 15
    jal get_location_address

    addi $a0, $v0, 0            # Put return value in $a0
    la $t0, MY_COLOURS
    la $a1, 8($t0)          # colour_address = &MY_COLOURS[2]
    li $a2, 30
    jal draw_hori_line               # Draw blue line 
    
    end_level_1:
   
# Draw the superblock
    li $a0, 16
    li $a1, 12
    jal get_location_address
    lw $t0, MY_COLOURS + 32
    sw $t0, ($v0)
    
# Draw the unbreakable brick
    li $a0, 9
    li $a1, 9
    jal get_location_address
    lw $t0, MY_COLOURS + 12
    sw $t0, ($v0)
    
    li $a0, 13
    li $a1, 9
    jal get_location_address
    lw $t0, MY_COLOURS + 12
    sw $t0, ($v0)
    
    li $a0, 22
    li $a1, 9
    jal get_location_address
    lw $t0, MY_COLOURS + 12
    sw $t0, ($v0)
    
    li $a0, 18
    li $a1, 9
    jal get_location_address
    lw $t0, MY_COLOURS + 12
    sw $t0, ($v0)
    
# Draw the paddle

    li $a0, 13
    li $a1, 29
    jal get_location_address

    addi $a0, $v0, 0            	# Put return value in $a0
    la $a1, MY_COLOURS + 20         # colour = yellow
    li $a2, 7
    jal draw_hori_line               # Draw white line
    
    
# Draw the ball
    li $t0, WHITE			# t0 = white
    lw $a0, DYNAMIC_LOCATION + 4	# a0 = x_ball_location
    lw $a1, DYNAMIC_LOCATION + 8	# a1 = y_ball_location
    jal get_location_address
    sw $t0, 0($v0) 
    
    b game_loop
    
update_surrounding_tiles:
    lw $t0, DYNAMIC_LOCATION + 4	# 
    lw $t1, DYNAMIC_LOCATION + 8	# t0, t1 = ball coordinate
    
    addi $a0, $t0, -1				
    addi $a1, $t1, -1				
    jal get_location_address		# v0 = address of that tile
    lw $t2, ($v0)					# t2 = the color of that tile
    sw $t2, TILE_UPPER_LEFT			# update tile color
    
    addi $a0, $t0, 0				
    addi $a1, $t1, -1				
    jal get_location_address		# v0 = address of that tile
    lw $t2, ($v0)					# t2 = the color of that tile
    sw $t2, TILE_UP					# update tile color
    
    addi $a0, $t0, 1				
    addi $a1, $t1, -1				
    jal get_location_address		# v0 = address of that tile
    lw $t2, ($v0)					# t2 = the color of that tile
    sw $t2, TILE_UPPER_RIGHT		# update tile color
    
    addi $a0, $t0, -1				
    addi $a1, $t1, 0				
    jal get_location_address		# v0 = address of that tile
    lw $t2, ($v0)					# t2 = the color of that tile
    sw $t2, TILE_LEFT				# update tile color
    
    addi $a0, $t0, 1				
    addi $a1, $t1, 0				
    jal get_location_address		# v0 = address of that tile
    lw $t2, ($v0)					# t2 = the color of that tile
    sw $t2, TILE_RIGHT				# update tile color
    
    addi $a0, $t0, -1				
    addi $a1, $t1, 1				
    jal get_location_address		# v0 = address of that tile
    lw $t2, ($v0)					# t2 = the color of that tile
    sw $t2, TILE_LOWER_LEFT			# update tile color
    
    addi $a0, $t0, 0				
    addi $a1, $t1, 1				
    jal get_location_address		# v0 = address of that tile
    lw $t2, ($v0)					# t2 = the color of that tile
    sw $t2, TILE_DOWN				# update tile color
    
    addi $a0, $t0, 1				
    addi $a1, $t1, 1				
    jal get_location_address		# v0 = address of that tile
    lw $t2, ($v0)					# t2 = the color of that tile
    sw $t2, TILE_LOWER_RIGHT		# update tile color
    
    b update_surrounding_tiles_finish


# ========================================================================
#
#
# GAME
# LOOP
#
#
# ========================================================================
game_loop:
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep
    #5. Go back to 1    
    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed
    
    la $t7, DYNAMIC_LOCATION
    lw $t7, DYNAMIC_LOCATION + 8	# t7 = ball location y
    bge $t7, 31, ball_reach_bottom

    addi $t9, $t9, 1				# counter += 1
    sge $t0, $t9, FRAME_DELAY		# t0 = (counter >= 100)
    
    beqz $t0, end_if				# if t0 == 0, goto end_if
    li $t9, 0						# counter = 0
    
    # Update surrounding tiles
    addi $sp, $sp, -4				# update_surrounding_tiles uses t0,
    sw $t0, ($sp)					# so store it to stack for now
    b update_surrounding_tiles
    update_surrounding_tiles_finish:
    lw $t0, ($sp)					# retrive t0 from stack
    addi $sp, $sp, 4				# 
    
    b move_ball
    move_ball_finish:
    
    li $v0, 32				# sleep function
    li $a0, SLEEP_DELAY
    syscall					
    
    end_if:
    b game_loop
    
    
ball_reach_bottom:
	li $v0, 10                      # Quit gracefully
	syscall

keyboard_input:                     # A key is pressed
    lw $a0, 4($t0)                  # Load second word from keyboard
    
    beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed    	
    beq $a0, 0x61, respond_to_A
    beq $a0, 0x64, respond_to_D
    beq $a0, 0x70, respond_to_P

    b game_loop

respond_to_Q:
	li $v0, 10                      # Quit gracefully
	syscall

respond_to_A:
	la $t2, DYNAMIC_LOCATION  #t2 = location address
	lw $t1, 0($t2)            # loaded x axis of the paddle left most position 
	bge $t1, 2, move_A        # t1 = location value
	b game_loop
	
respond_to_D:
    la $t2, DYNAMIC_LOCATION
	lw $t1, 0($t2)           # loaded x axis of the paddle left most position 
	ble $t1, 23, move_D     
	b game_loop

respond_to_P:
    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, p_action            # If first word 1, key is pressed
    li $v0, 32
    li $a0, 500
    syscall
    b respond_to_P
    
p_action:
    lw $a0, 4($t0)                  # Load second word from keyboard
    beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed    
    beq $a0, 0x70, game_loop        # Check if the key p was pressed
    
move_A:	
    addi $t1, $t1, -1           #new address after move (in 32 byte)
    sw $t1, 0($t2)
    	
    addi $a0, $t1, 0          
    li $a1, 29
    jal get_location_address   # new address after move (in address)
    
    la $t0, MY_COLOURS          
    lw $t0, 24($t0)            #t0 = black colour
    sw $t0, 28($v0)          #change colour for the address
    
    la $t0, MY_COLOURS          
    lw $t0, 20($t0)            #t0 = yellow colour
    sw $t0, ($v0)          #change colour for the address
    b game_loop
	
move_D:
    addi $t1, $t1, +1          #new address after move (in 32 byte)
    sw $t1, 0($t2)
    	
    addi $a0, $t1, 0          
    li $a1, 29
    jal get_location_address   # new address after move (in address)
    
    la $t0, MY_COLOURS          
    lw $t0, 24($t0)            #t0 = black colour
    sw $t0, -4($v0)          #change colour for the address
    
    la $t0, MY_COLOURS          
    lw $t0, 20($t0)            #t0 = yellow colour
    sw $t0, 24($v0)          #change colour for the address
    b game_loop

# ========================================================================
# MOVE
# BALL
#
# And utilities functions like
# straight move 
# diagonal move
# ========================================================================
move_ball:
	lw $a0, DYNAMIC_LOCATION + 4	# a0 = x_ball_location
	lw $a1, DYNAMIC_LOCATION + 8	# a1 = y_ball_location
	lw $a2, DYNAMIC_LOCATION + 12	# a2 = ball_direction
	jal delete_grid
	
	beq $a2, 1, call_straight_move
	beq $a2, 3, call_straight_move
	beq $a2, 5, call_straight_move
	beq $a2, 7, call_straight_move
	beq $a2, 2, call_diagonal_move
	beq $a2, 4, call_diagonal_move
	beq $a2, 6, call_diagonal_move
	beq $a2, 8, call_diagonal_move
	
	call_straight_move:
		jal straight_move
		b end_move
		
	call_diagonal_move:
		jal diagonal_move
		b end_move
	    
	end_move:
	
	# Draw ball at new location
	la $a0, ($t0)					# a0 = x_ball_location
	la $a1, ($t1)					# a1 = y_ball_location
	li $a2, WHITE					# a2 = white
	jal draw_grid

	b move_ball_finish

# straight_move(a0: ball location x, a1: ball location y, a2: ball direction) -> void
straight_move:
	addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    addi $t0, $a0, 0			# t0 = ball location x
	addi $t1, $a1, 0			# t1 = ball location y
	addi $t2, $a2, 0			# t2 = ball direction
	
	beq $a2, 1, case_up
	beq $a2, 3, case_right
	beq $a2, 5, case_down
	beq $a2, 7, case_left
	
	case_up:
	lw $t3, TILE_UP				# t3 = upper tile colour
	addi $t4, $0, 0				# t4 = 0 (x offset)
	addi $t5, $0, -1			# t5 = 1 (y offset)
	b end_straight_direction
	
	case_right:
	lw $t3, TILE_RIGHT
	addi $t4, $0, 1
	addi $t5, $0, 0
	b end_straight_direction
	
	case_down:
	lw $t3, TILE_DOWN
	addi $t4, $0, 0
	addi $t5, $0, 1
	b end_straight_direction
	
	case_left:
	lw $t3, TILE_LEFT
	addi $t4, $0, -1
	addi $t5, $0, 0
	b end_straight_direction
	
	end_straight_direction:
	
	beq $t3, BLACK, straight_move_end_if
	beq $t3, YELLOW, straight_move_paddle_deflect
	
	straight_move_vertical_deflect:
		add $a0, $t0, $t4					# collision tile x = t0 + t4
		add $a1, $t1, $t5					# collision tile y = t1 + t5
		jal trigger_collision
		
		# invert the offset and direction
		li $t7, -1							# t7 = -1
		mult $t4, $t7
		mflo $t4							# t4 = -t4
		mult $t5, $t7
		mflo $t5							# t5 = -t5
		
		addi $a0, $t2, 0
		jal invert_direction
		addi $t2, $v0, 0
		
		b straight_move_end_if
		
	straight_move_paddle_deflect:
		jal paddle_collision_check		# CAUTION: This function intentionally mutates t4, t5, t2
		b straight_move_end_if
		
	straight_move_end_if:
	
	add $t0, $t0, $t4					# x = x + offset
	add $t1, $t1, $t5					# y = y + offset
	
	sw $t0, DYNAMIC_LOCATION + 4	# x_ball_location = t0
	sw $t1, DYNAMIC_LOCATION + 8	# y_ball_location = t1
	sw $t2, DYNAMIC_LOCATION + 12	# ball_direction = t2
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
	
# diagonal_move(a0: ball location x, a1: ball location y, a2: ball direction) -> void
diagonal_move:
	addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    addi $t0, $a0, 0			# t0 = ball location x
	addi $t1, $a1, 0			# t1 = ball location y
	addi $t2, $a2, 0			# t2 = ball direction
	
	beq $a2, 2, case_upper_right
	beq $a2, 4, case_lower_right
	beq $a2, 6, case_lower_left
	beq $a2, 8, case_upper_left
	
	case_upper_right:
	lw $s0, TILE_UP				# s0 = verticle adjacent tile colour
	lw $s1, TILE_RIGHT			# s1 = horizontal adjacent tile colour
	lw $s2, TILE_UPPER_RIGHT	# s2 = diagonal adjacent tile colour
	addi $t4, $0, 1				# t4 = 1 (x offset)
	addi $t5, $0, -1			# t5 = -1 (y offset)
	b end_diagonal_direction
	
	case_lower_right:
	lw $s0, TILE_DOWN
	lw $s1, TILE_RIGHT
	lw $s2, TILE_LOWER_RIGHT
	addi $t4, $0, 1				# t4 = 1 (x offset)
	addi $t5, $0, 1				# t5 = 1 (y offset)
	b end_diagonal_direction
	
	case_lower_left:
	lw $s0, TILE_DOWN
	lw $s1, TILE_LEFT
	lw $s2, TILE_LOWER_LEFT
	addi $t4, $0, -1			# t4 = -1 (x offset)
	addi $t5, $0, 1				# t5 = 1 (y offset)
	b end_diagonal_direction
	
	case_upper_left:
	lw $s0, TILE_UP
	lw $s1, TILE_LEFT
	lw $s2, TILE_UPPER_LEFT
	addi $t4, $0, -1			# t4 = -1 (x offset)
	addi $t5, $0, -1			# t5 = -1 (y offset)
	b end_diagonal_direction
	
	end_diagonal_direction:
	
	beq $s0, YELLOW, diagonal_move_paddle_deflect
	
	sne $s0, $s0, BLACK			# s0 = (verticle adjacent tile not empty)
	sne $s1, $s1, BLACK			# s1 = (horizontal adjacent tile not empty)
	sne $s2, $s2, BLACK			# s2 = (diagonal adjacent tile not empty)
	
	bnez $s0, diagonal_move_vertical_deflect		# if s0 == 1, deflect vertically
	bnez $s1, diagonal_move_horizontal_deflect		# if s0 == 0 && s1 == 1, deflect horizontally
	bnez $s2, diagonal_move_diagonal_deflect		# if s0 == 0 && s1 == 0 && s2 == 1, deflect diagonally
		
	diagonal_move_no_collision:			# if s0 == 0, nothing happens
		b diagonal_move_end_if
	
	diagonal_move_vertical_deflect:
		bnez $s1, diagonal_move_diagonal_deflect	# if s0 == 1 && s1 == 1, deflect diagonally

		addi $a0, $t0, 0					# collision tile x = t0
		add $a1, $t1, $t5					# collision tile y = t1 + t5
		jal trigger_collision
		
		# invert the offset and direction
		li $t7, -1							# t7 = -1
		mult $t5, $t7
		mflo $t5							# t5 = -t5
		
		beq $t2, 2, vertical_deflect_case_1
		beq $t2, 4, vertical_deflect_case_2
		beq $t2, 6, vertical_deflect_case_3
		beq $t2, 8, vertical_deflect_case_4
		
		vertical_deflect_case_1:
		addi $t2, $0, 4
		b vertical_deflect_case_end
		vertical_deflect_case_2:
		addi $t2, $0, 2
		b vertical_deflect_case_end
		vertical_deflect_case_3:
		addi $t2, $0, 8
		b vertical_deflect_case_end
		vertical_deflect_case_4:
		addi $t2, $0, 6
		b vertical_deflect_case_end
	
		vertical_deflect_case_end:
		
		b diagonal_move_end_if
		
	diagonal_move_horizontal_deflect:
		# TODO need change
		add $a0, $t0, $t4					# collision tile x = t0 + t4
		addi $a1, $t1, 0					# collision tile y = t1
		jal trigger_collision
		
		# invert the offset and direction
		li $t7, -1							# t7 = -1
		mult $t4, $t7
		mflo $t4							# t4 = -t4
		
		addi $t2, $t2, -10					# Turns out, there are 4 possible cases:
		mult $t2, $t7						# 2->8; 4->6; 6->4; 8->2; 
		mflo $t2							# new direction = 10 - old direction = -1 * (old direction - 10)
		
		b diagonal_move_end_if
		
	diagonal_move_diagonal_deflect:
		add $a0, $t0, $t4					# collision tile x = t0 + t4
		add $a1, $t1, $t5					# collision tile y = t1 + t5
		jal trigger_collision
		
		# invert the offset and direction
		li $t7, -1							# t7 = -1
		mult $t4, $t7
		mflo $t4							# t4 = -t4
		mult $t5, $t7
		mflo $t5							# t5 = -t5
		
		addi $a0, $t2, 0
		jal invert_direction
		addi $t2, $v0, 0
		
		b diagonal_move_end_if
		
	diagonal_move_paddle_deflect:
		jal paddle_collision_check		# CAUTION: This function intentionally mutates t4, t5, t2
		b straight_move_end_if
		
	diagonal_move_end_if:
	
	add $t0, $t0, $t4					# x = x + offset
	add $t1, $t1, $t5					# y = y + offset
	
	sw $t0, DYNAMIC_LOCATION + 4	# x_ball_location = t0
	sw $t1, DYNAMIC_LOCATION + 8	# y_ball_location = t1
	sw $t2, DYNAMIC_LOCATION + 12	# ball_direction = t2
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra

# This function intentionally mutates t4, t5, t2
paddle_collision_check:
	addi $sp, $sp, -4
    sw $ra, 0($sp)
    
	lw $t8, DYNAMIC_LOCATION			# t8 = paddle_x
	
	li $t7, -1							# t7 = -1
	mult $t8, $t7
	mflo $t8							
	
	add $t8, $t0, $t8					# t8 = t0 - t8
	
	ble $t8, 1, paddle_deflect_left
	bge $t8, 5, paddle_deflect_right
	
	paddle_deflect_straight:
		addi $t4, $0, 0
		addi $t5, $0, -1
		addi $t2, $0, 1
		b paddle_deflect_end_if
	paddle_deflect_left:
		addi $t4, $0, -1
		addi $t5, $0, -1
		addi $t2, $0, 8
		b paddle_deflect_end_if
	paddle_deflect_right:
		addi $t4, $0, 1
		addi $t5, $0, -1
		addi $t2, $0, 2
		b paddle_deflect_end_if
		
	paddle_deflect_end_if:
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
	
# invert_direction(a0: ball direction, must within 1-8) -> inverted direction
invert_direction:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	addi $v0, $a0, 4			# This block of codes invert the ball direction
	blt	$v0, 9, finish_invert	# Since the direction is represented by 1-8
	addi $v0, $v0, -8			# Adding 4 can invert, if out of bound, minus 8
	
	finish_invert:
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
	
#paddle_collision_check:
	
	
# trigger_collision(a0: tile x coordinate, a1: tile y coordinate) -> The collision tile is paddle (1 or 0)
trigger_collision:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	addi $sp, $sp, -4
	sw $t1, ($sp)
	
	jal get_location_address		# v0 = tile address
	lw $t1, ($v0)					# t1 = tile colour
	
	beq $t1, GREY, end_trigger_collision
	beq $t1, YELLOW, end_trigger_collision	
	
	brick_collision:
		jal delete_grid

	end_trigger_collision:
	
	seq $v0, $t1, YELLOW			# v0 = (collision tile is paddle)
	
	lw $t1, ($sp)
	addi $sp, $sp, 4
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra

#delete_grid(x_location([0,31]), y_location([0,31])) -> void
delete_grid:
    addi $sp, $sp, -4
    sw $ra, 0($sp) 
    addi $sp, $sp, -4
	sw $t0, ($sp)
	addi $sp, $sp, -4
	sw $t1, ($sp)
    
    jal get_location_address	# v0 = tile address
    lw $t1, 0($v0)				# t1 = tile colour
    li $t0, BLACK  				# t0 = BLACK
    	beq $t1, GREEN, to_lightgreen   # intead of deleting, change green colour blocks to light green
    	end_lightgreen:
    sw $t0, 0($v0)				# tile colour <- BLACK 
    
    beq $t1, PURPLE, super_power         # activate super_power if that ball was hit. 
    end_super_power:   
    
    lw $t1, ($sp)
	addi $sp, $sp, 4
	lw $t0, ($sp)
	addi $sp, $sp, 4
    lw $ra, 0($sp)				
    addi $sp, $sp, 4
    jr $ra

to_lightgreen:
	li $t0, LIGHTGREEN
	b end_lightgreen
	

super_power:
	sw $t0, -12($v0)             #both left and right 3 pixela are cleared
        sw $t0, -8($v0)              
        sw $t0, -4($v0)
        sw $t0, 4($v0)
        sw  $t0, 8($v0)
        sw $t0, 12($v0)
	b end_super_power
    
#draw_grid(x_location([0,31]), y_location([0,31]), colour) -> void
draw_grid:
	addi $sp, $sp, -4
    sw $ra, 0($sp)
    
	jal get_location_address          
    sw $a2, 0($v0)             # colour
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
	
# get_location_address(x, y) -> address
#   Return the address of the unit on the display at location (x,y)
#
#   Preconditions:
#       - x is between 0 and 31, inclusive
#       - y is between 0 and 31, inclusive
get_location_address:
	addi $sp, $sp, -4
	sw $a0, ($sp)
	addi $sp, $sp, -4
	sw $a1, ($sp)

    # Each unit is 8 bytes. Each row has 32 units (256 bytes)
	sll 	$a0, $a0, 2
	sll 	$a1, $a1, 7            

    # Calculate return value
	la      $v0, ADDR_DSPL 			# res = address of ADDR_DSPL
    lw      $v0, 0($v0)             # res = address of (0, 0)
	add 	$v0, $v0, $a0			# res = address of (x, 0)
	add 	$v0, $v0, $a1           # res = address of (x, y)

	lw $a1, ($sp)
	addi $sp, $sp, 4
	lw $a0, ($sp)
	addi $sp, $sp, 4
    jr $ra

# draw_hori_line(start, colour_address, width) -> void
#   Draw a line with width units horizontally across the display using the
#   colour at colour_address and starting from the start address.
#
#   Preconditions:
#       - The start address can "accommodate" a line of width units
draw_hori_line:
    # Retrieve the colour
    lw $t0, 0($a1)              # colour = *colour_address

    # Iterate $a2 times, drawing each unit in the line
    li $t1, 0                   # i = 0
draw_hori_line_loop:
    slt $t2, $t1, $a2           # i < width ?
    beq $t2, $0, draw_hori_line_epi  # if not, then done

        sw $t0, 0($a0)          # Paint unit with colour
        addi $a0, $a0, 4        # Go to next unit

    addi $t1, $t1, 1            # i = i + 1
    b draw_hori_line_loop

draw_hori_line_epi:
    jr $ra
    

# draw_vert_line(start, colour_address, width) -> void
#   Draw a line with width units vertically across the display using the
#   colour at colour_address and starting from the start address.
#
#   Preconditions:
#       - The start address can "accommodate" a line of width units
draw_vert_line:
    # Retrieve the colour
    lw $t0, 0($a1)              # colour = *colour_address

    # Iterate $a2 times, drawing each unit in the line
    li $t1, 0                   # i = 0
draw_vert_line_loop:
    slt $t2, $t1, $a2           # i < height ?
    beq $t2, $0, draw_vert_line_epi  # if not, then done

        sw $t0, 0($a0)          # Paint unit with colour
        addi $a0, $a0, 128        # Go to next unit

    addi $t1, $t1, 1            # i = i + 1
    b draw_vert_line_loop

draw_vert_line_epi:
    jr $ra
