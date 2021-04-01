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
# - Milestone 2
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

.data

ship_colors:.word 0x263238,0x263238,0x263238,0x4a148c,0x000000,0x000000,        0x000000,0x000000,0x4a148c,0x4a148c,0x2195f3,0x000000,     0x263238,0x4a148c,0x4a148c,0x4a148c,0x4a148c,0xd50000

# Relative coordinates of colored tilesfor obstacles:
ast1_coord: .word 4,128,132,136,260
ast2_coord: .word 0,128,132
ship1_coord: .word 4,12,128,136,144,260,268

# relative pos to buffer frame
ast1_pos: .word 704
ast2_pos: .word 760
ship1_pos: .word 2600

.text
# $s0 stores ship_pos
.globl main
main:


# initialize relative ship position
li ship_pos, 1800
la ship_col, ship_colors # store ship color address


main_loop:

# algorithm to clear entire screen:
# ---------------- #
li $t9, 4092
li $t8, 0
clear:
sw $zero, BASE_ADDRESS($t8) # i think this should work
addi $t8,$t8,4
bne $t8,$t9,clear
# ----------------- #

# recieve input asdw and update ship position
# ------------------ #
li $t9, 0xffff0000 # load address to check MMIO event
lw $t8, 0($t9) # load value of MMIO event
bne $t8, 1, no_keystroke

lw $t0, 4($t9) # get ASCII value of key stroke into $t0

beq $t0, 97, pressed_a 
beq $t0, 100, pressed_d
beq $t0, 119, pressed_w
beq $t0, 115, pressed_s 

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
	addi $t1,$t1, -29
	beqz $t1, input_end # if y-29==0, ship is out of bounds and goto input_end
	li $t1,1  # to move 1 pixel down
	sll $t1,$t1,7 # since y coord starts after 7th bit
	add ship_pos, ship_pos, $t1 # y = y + 1
	j input_end

input_end:

# ----------------- #
no_keystroke:

#li $t1,1 # to move 1 pixel down
#sll $t1,$t1,7
#add $t0,$t0,$t1 # move down by 4(1 pixel)

# algorithm to render player ship:
# --------------- #
li $t8,68 # loop variable, x
render_ship:
add $t5, ship_col, $t8 # address of xth colour is in $t5

li $t2,24
div $t8,$t2 # x//24 into $t0
mflo $t0
mfhi $t1 # x%24 into $t1
#div $t0,$t8,24
 
sll $t0,$t0,7 # $t0 * 2^7 shift left 7
add $t0,$t0,$t1 # $ add in x%24
add $t0,$t0,ship_pos
addi $t0, $t0, BASE_ADDRESS
# t0 stores the pixel coordinate to colour

lw $t1, 0($t5)# load color,
sw $t1, 0($t0) # store colour on framebuffer

addi $t8,$t8,-4
bgez $t8, render_ship
# -------------------- #



# algorithm to astr1
# ------------------ #
la $t0, ast1_pos # load adress to ast1_pos
lw $t0, 0($t0) # load value of ast1_pos
addi $t0, $t0, BASE_ADDRESS # now $t0 stores absolute pos of where ast1 starts

li $t8,16 # 5 pixels in ast1
render_ast1:
lw $t1, ast1_coord($t8)# get relative pixel into $t1			# <--- I think this should work
add $t1,$t1,$t0 # relative pixel + ast1_pos into $t1
# now $t1 stores pixel to be coloredgrey =0x607d8b

li $t2,0x607d8b # load grey
sw $t2,0($t1) # make pixel grey

addi $t8,$t8,-4
bgez $t8,render_ast1
# ----------------- #

# algorithm to render astr2
# ------------------ #
la $t0, ast2_pos # load adress to ast1_pos
lw $t0, 0($t0) # load value of ast1_pos
addi $t0, $t0, BASE_ADDRESS # now $t0 stores absolute pos of where ast1 starts

li $t8,8 # 3 pixels in ast1
render_ast2:
lw $t1, ast2_coord($t8)# get relative pixel into $t1			# <--- I think this should work
add $t1,$t1,$t0 # relative pixel + ast1_pos into $t1
# now $t1 stores pixel to be coloredgrey =0x607d8b

li $t2,0x607d8b # load grey
sw $t2,0($t1) # make pixel grey

addi $t8,$t8,-4
bgez $t8,render_ast2
# ----------------- #



# algorithm to render ship1
# ------------------ #
la $t0, ship1_pos # load adress to ast1_pos
lw $t0, 0($t0) # load value of ast1_pos
addi $t0, $t0, BASE_ADDRESS # now $t0 stores absolute pos of where ast1 starts

li $t8,24 # 7 pixels in ast1 7*4-4
render_ship1:
lw $t1, ship1_coord($t8)# get relative pixel into $t1			# <--- I think this should work
add $t1,$t1,$t0 # relative pixel + ast1_pos into $t1
# now $t1 stores pixel to be coloredgrey =0x607d8b

li $t2,0x607d8b # load grey
sw $t2,0($t1) # make pixel grey

addi $t8,$t8,-4
bgez $t8,render_ship1
# ----------------- #


# update ast1_pos
# ------------------- #
# this astroid can only move left
la $t0, ast1_pos # address to ast1_pos
lw $t0, 0($t0) # $t0 holds value ast1_pos

# do a check to see out-of-bounds
sll $t1, $t0,25 # gets x coordinate in upper bits
beqz $t1, new_pos_ast1 # checks if x ==0, then get random pos

# compute next position
addi $t0, $t0, -4 # move left by 4(1 pixel)
j update_ast1

new_pos_ast1:# for if its out-of-bounds
# this happens if $t0==0 :
# pick number from 0 to 29 into $t0, this will be y coord
li $v0, 42 #load service number
li $a0, 0 #choose number generator
li $a1, 29 #max value
syscall
move $t0,$a0

sll $t0,$t0,7 # shift $t0 left 7
addi $t0, $t0,-12

update_ast1:
sw $t0,ast1_pos($zero) # update ast1_pos in memory
# ------------------ #


# update ast2_pos
# ------------------- #
# this astroid moves diagonally
la $t0, ast2_pos # address to ast2_pos
lw $t0, 0($t0) # $t0 holds value ast2_pos

# do a check to see out-of-bounds
sll $t1, $t0,25 # gets x coordinate in upper bits
beqz $t1, new_pos_ast2 # checks if x ==0, then out of bounds
srl $t1, $t0,7 # gets y coordinate in upper bits
beqz $t1, new_pos_ast2 # checks if y ==0, then out of bounds
addi $t1,$t1,-30 # compute y-30
beqz $t1, new_pos_ast2 # checks if y-30 ==0, then out of bounds

# compute new position
addi $t0, $t0, -8 # move left by 8(2 pixel) # speed can be changed here, be careful! init pos should be a multiple of this
li $t1,1 # to move 1 pixel down
sll $t1,$t1,7
add $t0,$t0,$t1 # move down by 4(1 pixel)

j update_ast2

new_pos_ast2: # for if its out-of-bounds
# this happens if $t0==0 :
# pick number from 0 to 29 into $t0, this will be y coord
li $v0, 42 #load service number
li $a0, 0 #choose number generator
li $a1, 29 #max value
syscall
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
#j update_ast1
beqz $t1, new_pos_ship1 # checks if x ==0, then get new position

# compute new position
addi $t0, $t0, -4 # move left by 4(1 pixel) # speed can be changed here, be careful! init pos should be a multiple of this
j update_ship1

new_pos_ship1:# for if its out-of-bounds
# this happens if $t0==0 :
# pick number from 0 to 29 into $t0, this will be y coord
li $v0, 42 #load service number
li $a0, 0 #choose number generator
li $a1, 29 #max value
syscall
move $t0,$a0

sll $t0,$t0,7 # shift $t0 left 7
addi $t0, $t0,-20 # square off with right side

update_ship1:
sw $t0,ship1_pos($zero) # update ast1_pos in memory
# ------------------ #






li $v0, 32
li $a0, 200 # Wait one second (1000 milliseconds)
syscall


j main_loop



li $v0, 10 # terminate the program gracefully
syscall

