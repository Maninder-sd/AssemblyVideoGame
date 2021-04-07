#####################################################################
#
# CSCB58 Winter 2021 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Maninder Dhanauta, 1004877608, dhanauta
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8 (update this as needed)
# - Unit height in pixels: 8 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 3
#
# Which approved features have been implemented for milestone 4?
# N/A
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# N/A
# #
#Are you OK with us sharing the video with people outside course staff?
# yes, https://github.com/Maninder-sd/AssemblyVideoGame
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

.eqv BASE_ADDRESS 0x10008000
.eqv ship_pos $s0 # absolute position in memory
.eqv ship_col $s1
.eqv damaged $s3



.data

# STATS:
health: .word 3960



# Relative coordinates of colored tiles:
# player ship:
ship_colors:.word 0x263238,0x263238,0x263238,0x4a148c,     0x4a148c,0x4a148c,0x2195f3,     0x263238,0x4a148c,0x4a148c,0x4a148c,0x4a148c,0xd50000
ship_coord: .word 0,4,8,12,     136,140,144,     256,260,264,268,272,276
# obstacles:
ast1_colors: .word 0x607d8b,0x607d8b,0x607d8b,0x607d8b,0x607d8b
ast1_coord: .word 4,128,132,136,260
ast2_colors: .word 0x607d8b,0xff4080,0x607d8b
ast2_coord: .word 0,128,132
ship1_colors: .word 0x607d8b,0xff5622,0x607d8b,0x607d8b,0x607d8b,0xff5622,0x607d8b
ship1_coord: .word 4,12,128,136,144,260,268

# relative start pos to buffer frame
ast1_pos: .word 704
ast2_pos: .word 760
ship1_pos: .word 2600

.text
# $s0 stores ship_pos
.globl main
main:

# initializa all variables:
# init ast1_pos:
	li $t0, 704
	sw $t0,ast1_pos
# init ast2_pos:
	li $t0, 760
	sw $t0,ast2_pos
# init ship1_pos:
	li $t0, 2600
	sw $t0,ship1_pos
# init health:
	li $t0, 3960
	sw $t0,health
# init damaged:
	li damaged,0


li ship_pos, 1800
la ship_col, ship_colors # store ship color address

# algorithm to clear entire screen:
# ---------------- #
li $t9, 4092
li $t8, 0
clear:
sw $zero, BASE_ADDRESS($t8) # i think this should work
addi $t8,$t8,4
bne $t8,$t9,clear
# ----------------- #

# setting up health bar:
# ---------------- #


# making white base 
	li $t9, 4092 # till end
	li $t8, 3712 # start from 29th row
	li $t0 0xf9a825
white_base:
	sw $t0, BASE_ADDRESS($t8) 
	addi $t8,$t8,4
	ble $t8,$t9,white_base
# making green bar 
	li $t9, 3960 # till end
	li $t8, 3908 # start from 29th row
	li $t0 0x00ff00
green_bar:
	sw $t0, BASE_ADDRESS($t8) 
	addi $t8,$t8,4
	ble $t8,$t9,green_bar
# making blue bar 
	li $t9, 3892 # till end
	li $t8, 3844 # start from 29th row
	li $t0 0x03a8f4
blue_bar:
	sw $t0, BASE_ADDRESS($t8) 
	addi $t8,$t8,4
	ble $t8,$t9,blue_bar
# making red dot
	li $t0 0xd50000
	li $t8, 3900
	sw $t0, BASE_ADDRESS($t8) 
# ---------------- #
main_loop:





# -------------------------------------------- CLEARING SCREEN -------------------------------------------------- #


# algorithm to clear player ship:
# --------------- #
addi $t1, ship_pos,BASE_ADDRESS# get abs position of ship

li $t8,48 # loop variable, x, 48/4+1 = 13 pixels in the ship
clear_ship:
# getting pixel address
	lw $t0, ship_coord($t8) # load relative address of xth pixel of ship
	add $t0,$t0,$t1# now $t0 is absolute address of xth pixel
# set pixel color to black
	sw $zero, 0($t0) # store black on framebuffer
addi $t8,$t8,-4#decrement counter
bgez $t8, clear_ship#check if counter x != 0, then loop
# -------------------- #

# algorithm to clear astr1
# ------------------ #
la $t1, ast1_pos # load adress to ast1_pos
lw $t1, 0($t1) # load value of ast1_pos
addi $t1, $t1,BASE_ADDRESS# get absolute position of where ast1 starts

li $t8,16 # loop variable, x, 16/4+1 = 5 pixels in the ship
clear_ast1:
# getting pixel address
	lw $t0, ast1_coord($t8) # load relative address of xth pixel of ast1
	add $t0,$t0,$t1# now $t0 is absolute address of xth pixel
# set pixel color to black
	sw $zero, 0($t0) # store colour on framebuffer
addi $t8,$t8,-4#decrement counter
bgez $t8, clear_ast1#check if counter x != 0, then loop
# ----------------- #

# algorithm to clear astr2
# ------------------ #
la $t1, ast2_pos # load adress to ast2_pos
lw $t1, 0($t1) # load value of ast2_pos
addi $t1, $t1,BASE_ADDRESS# get absolute position of where ast2 starts

li $t8,8 # loop variable, x, 8/4+1 = 3 pixels in ast2
clear_ast2:

# getting pixel address
	lw $t0, ast2_coord($t8) # load relative address of xth pixel of ast2
	add $t0,$t0,$t1# now $t0 is absolute address of xth pixel
# set pixel color to black
	sw $zero, 0($t0) # store colour on framebuffer
	
addi $t8,$t8,-4#decrement counter
bgez $t8, clear_ast2#check if counter x != 0, then loop
# ----------------- #



# algorithm to clear ship1
# ------------------ #
la $t1, ship1_pos # load adress to ship1_pos
lw $t1, 0($t1) # load value of ship1_pos
addi $t1, $t1,BASE_ADDRESS# get absolute position of where ship1 starts

li $t8,24 # loop variable, x, 24/4+1 = 7 pixels in the ship
clear_ship1:
# getting pixel address
	lw $t0, ship1_coord($t8) # load relative address of xth pixel of shp1
	add $t0,$t0,$t1# now $t0 is absolute address of xth pixel
# set pixel color to black
	sw $zero, 0($t0) # store colour on framebuffer
	
addi $t8,$t8,-4#decrement counter
bgez $t8, clear_ship1 # check if counter x != 0, then loop
# ----------------- #




# -------------------------------------------- CLEARING SCREEN ENDS -------------------------------------------------- #





# -------------------------------------------- UPDATING LOCATIONS -------------------------------------------------- #


# recieve input asdw and update ship position
# ------------------ #
li $t9, 0xffff0000 # load address to check MMIO event
lw $t8, 0($t9) # load value of MMIO event
bne $t8, 1, input_end

lw $t0, 4($t9) # get ASCII value of key stroke into $t0

beq $t0, 97, pressed_a 
beq $t0, 100, pressed_d
beq $t0, 119, pressed_w
beq $t0, 115, pressed_s 
beq $t0, 112, pressed_p
j input_end

pressed_a: # move left
# check if out of bounds
	sll $t1, ship_pos, 25 # $t1 is non-zero when x is non-zero
	beqz $t1, input_end # if x = 0, then ship is at left bound of map, goto end
	addi ship_pos,ship_pos,-4# moves position to left
	j input_end
pressed_d: # move right
# check if out of bounds
	addi $t1, ship_pos,-104
	sll $t1, $t1, 25 # $t1 is non-zero when x-104 is non-zero
	beqz $t1, input_end # if x-104=0, ship is at right bound of map
	addi ship_pos,ship_pos,4 # moves position to right
	j input_end
pressed_w: # move up
# check if out of bounds:
	srl $t1, ship_pos, 7 # $t1 now stores y coord
	beqz $t1, input_end # if y==0, ship is out of bounds and goto input_end
	li $t1,1  # to move 1 pixel up
	sll $t1,$t1,7 # since y coord starts after 7th bit
	sub ship_pos, ship_pos, $t1 #  y = y -1
	j input_end
pressed_s: # move down
# check if out of bounds:
	srl $t1, ship_pos, 7 # $t1 now stores y coord
	addi $t1,$t1, -26
	beqz $t1, input_end # if y-29==0, ship is out of bounds and goto input_end
	li $t1,1  # to move 1 pixel down
	sll $t1,$t1,7 # since y coord starts after 7th bit
	add ship_pos, ship_pos, $t1 # y = y + 1
	j input_end
pressed_p:
	j main
input_end:
# ----------------- #

# ------- update ast1_pos ----------#
# this astroid can only move left at speed 1 pixel, from pixel 0-26

la $t0, ast1_pos # address to ast1_pos
lw $t0, 0($t0) # $t0 holds value ast1_pos

# do a check to see out-of-bounds
	sll $t1, $t0,25 # gets x coordinate in upper bits
	beqz $t1, new_pos_ast1 # checks if x ==0, then get random pos
# compute next position
	addi $t0, $t0, -4 # move left by 4(1 pixel)
	j update_ast1
# choose new y coord when out of bounds
new_pos_ast1:
	li $v0, 42 #load service number
	li $a0, 0 #choose number generator
	li $a1, 26 # pick number from 0-26
	syscall
# setting y coord:
	move $t0,$a0
	sll $t0,$t0,7 # shift $t0 left 7
	addi $t0, $t0,-12
update_ast1:
	sw $t0,ast1_pos($zero) # update ast1_pos in memory
# ------------------ #


# update ast2_pos
# ------------------- #
# this astroid moves left-down at rate (-2,1)

la $t0, ast2_pos # address to ast2_pos
lw $t0, 0($t0) # $t0 holds value ast2_pos

# do a check to see out-of-bounds
	sll $t1, $t0,25 # gets x coordinate in upper bits
	beqz $t1, new_pos_ast2 # checks if x ==0, then out of bounds
	srl $t1, $t0,7 # gets y coordinate in upper bits
	beqz $t1, new_pos_ast2 # checks if y ==0, then out of bounds
	addi $t1,$t1,-27 # compute y-30
	beqz $t1, new_pos_ast2 # checks if y-30 ==0, then out of bounds

# compute next position
	addi $t0, $t0, -8 # move left by 8(2 pixel) # speed can be changed here, be careful! init pos should be a multiple of this
	li $t1,1 # to move 1 pixel down
	sll $t1,$t1,7
	add $t0,$t0,$t1 # move down by 4(1 pixel)
	j update_ast2
# choose new y coord when out of bounds
new_pos_ast2:
	li $v0, 42 #load service number
	li $a0, 0 #choose number generator
	li $a1, 26 #max value
	syscall
# setting y coord:
	move $t0,$a0
	sll $t0,$t0,7 # shift $t0 left 7
	addi $t0, $t0,-8 # square off with right side

update_ast2:
	sw $t0,ast2_pos($zero) # update ast1_pos in memory
# ------------------ #


# update ship1_pos
# ------------------- #
# this ship can only move left
la $t0, ship1_pos # address to ship1_pos
lw $t0, 0($t0) # $t0 holds value ship1_pos

# do a check to see out-of-bounds
	sll $t1, $t0,25 # gets x coordinate in upper bits
	beqz $t1, new_pos_ship1 # checks if x ==0, then get new position
# compute next position
	addi $t0, $t0, -4 # move left by 4(1 pixel) # speed can be changed here, be careful! init pos should be a multiple of this
	j update_ship1
# choose new y coord when out of bounds
new_pos_ship1:
	li $v0, 42 #load service number
	li $a0, 0 #choose number generator
	li $a1, 26 #max value
	syscall
# setting y coord:
	move $t0,$a0
	sll $t0,$t0,7 # shift $t0 left 7
	addi $t0, $t0,-20 # square off with right side

update_ship1:
	sw $t0,ship1_pos($zero) # update ast1_pos in memory
# ------------------ #
# -------------------------------------------- UPDATING ENDS -------------------------------------------------- #



# -------------------------------------------- RENDERING -------------------------------------------------- #

# algorithm to render player ship:
# --------------- #
addi $t1, ship_pos,BASE_ADDRESS# get abs position of ship

li $t8,48 # loop variable, x, 48/4+1 = 13 pixels in the ship
render_ship:
#getting pixel color
	la $t5, ship_colors
	add $t5, $t5, $t8 # address of xth colour is into $t5
	lw $t5, 0($t5)# load color into $t5
# getting pixel address
	lw $t0, ship_coord($t8) # load relative address of xth pixel of ship
	add $t0,$t0,$t1# now $t0 is absolute address of xth pixel
# displaying pixel color
	sw $t5, 0($t0) # store colour on framebuffer
	
addi $t8,$t8,-4#decrement counter
bgez $t8, render_ship#check if counter x != 0, then loop
# -------------------- #



# algorithm to astr1
# ------------------ #
la $t1, ast1_pos # load adress to ast1_pos
lw $t1, 0($t1) # load value of ast1_pos
addi $t1, $t1,BASE_ADDRESS# get absolute position of where ast1 starts

li $t8,16 # loop variable, x, 16/4+1 = 5 pixels in the ship
render_ast1:
#getting pixel color
	la $t5, ast1_colors
	add $t5, $t5, $t8 # address of xth colour is into $t5
	lw $t5, 0($t5)# load color into $t5
# getting pixel address
	lw $t0, ast1_coord($t8) # load relative address of xth pixel of ast1
	add $t0,$t0,$t1# now $t0 is absolute address of xth pixel
# check for collision:
	lw $t2, 0($t0) # pixel color to check
	# checks if cuurent color is ship colors: 0x263238,0x4a148c,0xd50000
	beq $t2,  0x263238, ast1_col_detected
	beq $t2, 0x4a148c, ast1_col_detected
	beq $t2, 0xd50000, ast1_col_detected
	j ast1_col_end
ast1_col_detected:
	li damaged, 1 # damage done by ast1	
	li $t2,0 # reset position ast1
	sw $t2, ast1_pos($zero)
	j ast1_render_end # stop rendering 
ast1_col_end:
# displaying pixel color
	sw $t5, 0($t0) # store colour on framebuffer
	
addi $t8,$t8,-4#decrement counter
bgez $t8, render_ast1#check if counter x != 0, then loop
ast1_render_end:
# ----------------- #

# algorithm to render astr2
# ------------------ #
la $t1, ast2_pos # load adress to ast2_pos
lw $t1, 0($t1) # load value of ast2_pos
addi $t1, $t1,BASE_ADDRESS# get absolute position of where ast2 starts

li $t8,8 # loop variable, x, 8/4+1 = 3 pixels in ast2
render_ast2:
#getting pixel color
	la $t5, ast2_colors
	add $t5, $t5, $t8 # address of xth colour is into $t5
	lw $t5, 0($t5)# load color into $t5
# getting pixel address
	lw $t0, ast2_coord($t8) # load relative address of xth pixel of ast2
	add $t0,$t0,$t1# now $t0 is absolute address of xth pixel
# check for collision:
	lw $t2, 0($t0) # pixel color to check
	# checks if cuurent color is ship colors: 0x263238,0x4a148c,0xd50000
	beq $t2,  0x263238, ast2_col_detected
	beq $t2, 0x4a148c, ast2_col_detected
	beq $t2, 0xd50000, ast2_col_detected
	j ast2_col_end
ast2_col_detected:
	li damaged, 1 # damage done by ast1
	li $t2,0 # reset position ast1
	sw $t2, ast2_pos($zero)
	j ast2_render_end # stop rendering 
ast2_col_end:
# displaying pixel color
	sw $t5, 0($t0) # store colour on framebuffer
	
addi $t8,$t8,-4#decrement counter
bgez $t8, render_ast2#check if counter x != 0, then loop
ast2_render_end:
# ----------------- #



# algorithm to render ship1
# ------------------ #
la $t1, ship1_pos # load adress to ship1_pos
lw $t1, 0($t1) # load value of ship1_pos
addi $t1, $t1,BASE_ADDRESS# get absolute position of where ship1 starts

li $t8,24 # loop variable, x, 24/4+1 = 7 pixels in the ship
render_ship1:
#getting pixel color
	la $t5, ship1_colors
	add $t5, $t5, $t8 # address of xth colour is into $t5
	lw $t5, 0($t5)# load color into $t5
# getting pixel address
	lw $t0, ship1_coord($t8) # load relative address of xth pixel of shp1
	add $t0,$t0,$t1# now $t0 is absolute address of xth pixel
# check for collision:
	lw $t2, 0($t0) # pixel color to check
	# checks if cuurent color is ship colors: 0x263238,0x4a148c,0xd50000
	beq $t2,  0x263238, ship1_col_detected
	beq $t2, 0x4a148c, ship1_col_detected
	beq $t2, 0xd50000, ship1_col_detected
	j ship1_col_end
ship1_col_detected:
	li damaged, 1 # damage done by ast1
	li $t2,0 # reset position ast1
	sw $t2, ship1_pos($zero)
	j ship1_render_end # stop rendering 
ship1_col_end:
# displaying pixel color
	sw $t5, 0($t0) # store colour on framebuffer
	
addi $t8,$t8,-4#decrement counter
bgez $t8, render_ship1 # check if counter x != 0, then loop
ship1_render_end:
# ----------------- #



# render health bar
# ----------------#
bne damaged,1,no_damage #check if damage is done
	lw $t0, health($zero) #loads current health bar
	sw $zero, BASE_ADDRESS($t0) # blacks out a health
	addi $t0,$t0,-4 # decrements the health
	sw $t0, health # updates the new health
	beq $t0, 3904, game_over # checks if health is done
	li damaged,0
no_damage:

# ----------------#

# -------------------------------------------- RENDERING ENDS -------------------------------------------------- #

li $v0, 32
li $a0, 80 # Wait one second (1000 milliseconds)
syscall
j main_loop

game_over:

# making red base 
	li $t9, 2684 # till 17th
	li $t8, 640 # start from 13th row
	li $t0 0x9c27b0
red_base:
	sw $t0, BASE_ADDRESS($t8) 
	addi $t8,$t8,4
	ble $t8,$t9,red_base
# print F:
	li $t0, BASE_ADDRESS
	li $t1, 0x4caf4f #
	sw $t1, 1588($t0)
	sw $t1, 1592($t0)
	sw $t1, 1596($t0)

	sw $t1, 1716($t0)

	sw $t1, 1844($t0)
	sw $t1, 1848($t0)
	sw $t1, 1852($t0)
	
	sw $t1, 1972($t0)
	sw $t1, 2100($t0)


resetting:
	li $v0, 32
	li $a0, 80 # Wait one second (1000 milliseconds)
	syscall

	li $t9, 0xffff0000 # load address to check MMIO event
	lw $t8, 0($t9) # load value of MMIO event
	bne $t8, 1, resetting # jump if not keystoke

	lw $t0, 4($t9) # get ASCII value of key stroke into $t0
	beq $t0, 112, pressed_p
	j resetting


li $v0, 10 # terminate the program gracefully
syscall

