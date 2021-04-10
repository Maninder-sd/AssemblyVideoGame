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

.eqv timer $s4
.eqv timer_bar $s5

.eqv SLEEP 80 
.eqv LEVEL_1_LENGTH 10 # level 1 runs for 60*13= 780 cycles = 31.2 sec
.eqv LEVEL_2_LENGTH 30 # level 1 runs for 60*13= 780 cycles = 31.2 sec


.data

# STATS:
health: .word 3960



# Relative coordinates of colored tiles:
# player ship:
ship_colors:.word 0x263238,0x263238,0x263238,0x4a148c,     0x4a148c,0x4a148c,0x2195f3,     0x263238,0x4a148c,0x4a148c,0x4a148c,0x4a148c,0xd50000
ship_coord: .word 0,4,8,12,     136,140,144,     256,260,264,268,272,276

# obstacles:
ast1_colors: .word 0x607d8b,0x607d8b,0x9e9e9e,0x607d8b,0x607d8b
ast1_coord: .word 4,128,132,136,260
ast1_pos: .word 0, 100, 300, 1500

# pink
mis1_colors: .word 0xd4d4d4,0xff4080,0xd4d4d4
mis1_coord: .word 0,128,132
mis1_pos: .word 1000
# blue
mis2_colors: .word 0x2195f3,0xd4d4d4,0xd4d4d4
mis2_coord: .word 0,4,128
mis2_pos: .word 100

heal_colors: .word 0xffffff,0x4caf4f,0xffffff,		0x8bc34a,0x4caf4f,0x4caf4f,	0xffffff, 0x8bc34a,0xffffff
heal_coord: .word 0,4,8,	128,132,136,	256,260,264

heal_pos:  .word 0
heal_start: .word 0 # 0 means timer isnt ready, 1 means is rendered, 2 means has collided, 3 means out-of-bounds





.text
# $s0 stores ship_pos
.globl main
main:









# init ship stuff:
	li ship_pos, 1800
	la ship_col, ship_colors # store ship color address
# init health:
	li $t0, 3960
	sw $t0,health
# init damaged:
	li damaged,0
# init timer stuff
	li timer,0#setting timer
	li timer_bar,3892# get location of blue timer bar, see below











# setting up health bar:
# ---------------- #
# making yellow base 
	li $t9, 4092 # till end
	li $t8, 3712 # start from 29th row
	li $t0 0xf9a825 #yellow colour
yellow_base:
	sw $t0, BASE_ADDRESS($t8) 
	addi $t8,$t8,4
	ble $t8,$t9,yellow_base
# making health bar 
	li $t9, 3960 # till end
	li $t8, 3908 # start from 29th row
	li $t0 0x00ff00 #green
health_bar:
	sw $t0, BASE_ADDRESS($t8) 
	addi $t8,$t8,4
	ble $t8,$t9,health_bar
# making timer bar 
	li $t9, 3892 # till end
	li $t8, 3844 # start from 29th row
	li $t0 0x03a8f4 #blue 
time_bar: # 13 pixels
	sw $t0, BASE_ADDRESS($t8) 
	addi $t8,$t8,4
	ble $t8,$t9,time_bar
# making reload dot
	li $t0 0xd50000 #red
	li $t8, 3900
	sw $t0, BASE_ADDRESS($t8) 
# ---------------- #

# algorithm to clear entire screen:
# ---------------- #
li $t9, 3712
li $t8, 0
clear:
sw $zero, BASE_ADDRESS($t8) 
addi $t8,$t8,4
bne $t8,$t9,clear
# ----------------- #


#j done_level_1 # THIS LINE SHOULD BE REMOVED AT THE END!!!!!

############# -------------------------------------------------------------------------- LEVEL 1 --------------------------------------------------------------------------------------- ###############

# In this level you must dodge 4 regular astroids for 30 seconds


level_1:

# -------------------------------------------- CLEARING SCREEN -------------------------------------------------- #
# algorithm to clear entire screen:
# ---------------- #
li $t9, 3712
li $t8, 0
clear1:
sw $zero, BASE_ADDRESS($t8) # i think this should work
addi $t8,$t8,4
bne $t8,$t9,clear1
# ----------------- #
# -------------------------------------------- CLEARING SCREEN ENDS -------------------------------------------------- #



# recieve input asdw and update ship position
# ------------------ #
	jal check_input
# ----------------- #


# ------- update ast1_pos ----------#
# this astroid can only move left at speed 1 pixel, from pixel 0-26

	jal updating_ast1 # function call
# ------------------ #



# -------------------------------------------- RENDERING -------------------------------------------------- #

# algorithm to render player ship:
# --------------- #
	jal rendering_ship
# -------------------- #


# algorithm to render astr1
# ------------------ #

	jal rendering_ast1 # function call to render all asrt1
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

# -------------------------------------------- RENDERING END -------------------------------------------------- #

li $v0, 32 #loading sleep service
li $a0, SLEEP # Wait
syscall

# timer stuff:
# ------------ #
addi timer,timer,1 # increment timer
blt timer,LEVEL_1_LENGTH,level_1 # check if 60 frames have passed

li timer, 0 # reset timer
sw $zero, BASE_ADDRESS(timer_bar)# reduce timer on timer_bar
addi timer_bar,timer_bar,-4 # decrement timer_bar address

beq timer_bar,3840, done_level_1 # if all of timer bar is decremented, goto done_level_1
# ----------- #
j level_1

############# -------------------------------------------------------------------------- LEVEL 1 ENDS --------------------------------------------------------------------------------------- ###############

done_level_1:
# algorithm to clear entire screen:
# ---------------- #
li $t9, 3712 # upper limit of loop vairable
li $t8, 0 # loop vairable
li $t0,0x795548 #brown
clear2:
	sw $t0, BASE_ADDRESS($t8) 
	addi $t8,$t8,4
	li $v0, 32 #loading sleep service
	li $a0, 5 # Wait to create an effect
	syscall
bne $t8,$t9,clear2
# ----------------- #
# print L 11:
	li $t0, BASE_ADDRESS
	li $t1, 0x4caf4f #green
	sw $t1, 1460($t0)
	sw $t1, 1472($t0)
	sw $t1, 1480($t0)
	
	sw $t1, 1588($t0)
	sw $t1, 1600($t0)
	sw $t1, 1608($t0)
	
	sw $t1, 1716($t0)
	sw $t1, 1720($t0)
	sw $t1, 1728($t0)
	sw $t1, 1736($t0)

	li $v0, 32 #loading sleep service
	li $a0, 2000 # Wait
	syscall

# resetting timer bar:
	li $t9, 3892 # till end
	li $t8, 3844 # start from 29th row
	li $t0 0x03a8f4 #blue 
time_bar1: # 13 pixels
	sw $t0, BASE_ADDRESS($t8) 
	addi $t8,$t8,4
	li $v0, 32 #loading sleep service
	li $a0, 80 # Wait
	syscall
	ble $t8,$t9,time_bar1 # if end not reached loop again
	
	li $v0, 32 #loading sleep service
	li $a0, 5000 # Wait
	syscall

# re-initialize stuff
	li ship_pos, 1800 # re-position ship
# init damaged:
	li damaged,0
# init timer stuff
	li timer,0#setting timer
	li timer_bar,3892# get location of blue timer bar, see below
	
# select random position for healing kit:
# -------------- #
	li $v0, 42 #load service number
	li $a0, 0 #choose number generator
	li $a1, 26 # pick number from 0-25
	syscall
	addi $t0,$a0,1 # make number between 1-26
	sll $t0,$t0,7 # shift random numeber into y coordinate space
	addi $t0,$t0,-12
	sw $t0,heal_pos
# --------------- #


li $t0, 0
sw $t0, heal_start

############# -------------------------------------------------------------------------- LEVEL 2 --------------------------------------------------------------------------------------- ###############

# in this level, you must dogde special enemy long range missiles that move diagonally
# additionally, you have a chance to pick up a healing k that appears once in the level
# so you can recharge before the next boss level 

level_2:

# -------------------------------------------- CLEARING SCREEN -------------------------------------------------- #
# algorithm to clear entire screen:
# ---------------- #
li $t9, 3712 # upper limit of loop vairable
li $t8, 0 # loop vairable
li $t0,0x795548 #brown
clear3:
	sw $t0, BASE_ADDRESS($t8) 
	addi $t8,$t8,4
bne $t8,$t9,clear3
# ----------------- #
# -------------------------------------------- CLEARING SCREEN ENDS-------------------------------------------------- #


# -------------------------------------------- UPDATE POSITIONS -------------------------------------------------- #

# recieve input asdw and update ship position
# ------------------ #
	jal check_input
# ----------------- #



# algorithm to update healing kit position
# ------------- #
# to update the position if still rendering
	lw $t0, heal_start # load status of heal_start
	bne $t0,1,next_kit_update # if heal_start !=1, skip
		lw $t0, heal_pos # get position of healing kitinto reg $t0
		# do a check to see out-of-bounds
		sll $t1, $t0,25 # gets x coordinate in upper bits
		bnez $t1, inc_heal_pos # checks if x !=0, go increment position
		li $t2,3
		sw $t2, heal_start # store out-of-bounds status into heal_start
		j no_kit_update

		# increment position
		inc_heal_pos:
		addi $t0,$t0,-4 # increment position
		sw $t0, heal_pos
		j no_kit_update

# TO display healing kit for first time:
next_kit_update:
	lw $t0, heal_start
	bnez $t0, no_kit_update # if heal_start !=0, skip
	
	bgt timer_bar, 3856,no_kit_update # if timer > 3586, skip
		li $t0,1
		sw $t0,heal_start # set heal_start=1 to start rendering
no_kit_update:

# ------------ #

# ------- update ast1_pos ----------#
# this astroid can only move left at speed 1 pixel, from pixel 0-26

	jal updating_ast1 # function call
# ------------------ #

# update mis1_pos
# ------------------- #
# this missile moves left-down at rate (-2,1)

lw $t0,  mis1_pos  # $t0 holds value mis1_pos

# do a check to see out-of-bounds
	sll $t1, $t0,25 # gets x coordinate in upper bits
	beqz $t1, new_pos_mis1 # checks if x ==0, then out of bounds
	srl $t1, $t0,7 # gets y coordinate to lower bits
	beqz $t1, new_pos_mis1 # checks if y ==0, then out of bounds
	addi $t1,$t1,-27 # compute y-27
	beqz $t1, new_pos_mis1 # checks if y-30 ==0, then out of bounds

# compute next position
	addi $t0, $t0, -8 # move left by 8(2 pixel) # speed can be changed here, be careful! init pos should be a multiple of this
	li $t1,1 # to move 1 pixel down
	sll $t1,$t1,7
	add $t0,$t0,$t1 # move down by 4(1 pixel)
	j update_mis1
# choose new y coord when out of bounds
new_pos_mis1:
	li $v0, 42 #load service number
	li $a0, 0 #choose number generator
	li $a1, 25 #max value 0-25
	syscall
# setting y coord:
	addi $t0,$a0,1 # y value from 1-26 
	sll $t0,$t0,7 # shift $t0 left 7
	addi $t0, $t0,-8 # square off with right side

update_mis1:
	sw $t0,mis1_pos# update mis2_pos in memory
# ------------------ #


#
#
#
#
#


# update mis2_pos
# ------------------- #
# this missile moves left-up at rate (-1,-1)

lw $t0,  mis2_pos  # $t0 holds value mis1_pos

# do a check to see out-of-bounds
	sll $t1, $t0,25 # gets x coordinate in upper bits
	beqz $t1, new_pos_mis2 # checks if x ==0, then out of bounds
	srl $t1, $t0,7 # gets y coordinate to lower bits
	beqz $t1, new_pos_mis2 # checks if y ==0, then out of bounds
	addi $t1,$t1,-27 # compute y-27
	beqz $t1, new_pos_mis2 # checks if y-30 ==0, then out of bounds

# compute next position
	addi $t0, $t0, -4 # move left by 4(1 pixel) # speed can be changed here, be careful! init pos should be a multiple of this
	li $t1,-1 # to move 1 pixel up
	sll $t1,$t1,7
	add $t0,$t0,$t1 # move down by 4(1 pixel)
	j update_mis2
# choose new y coord when out of bounds
new_pos_mis2:
	li $v0, 42 #load service number
	li $a0, 0 #choose number generator
	li $a1, 25 #max value 0-25
	syscall
# setting y coord:
	addi $t0,$a0,1 # y value from 1-26 
	sll $t0,$t0,7 # shift $t0 left 7
	addi $t0, $t0,-8 # square off with right side

update_mis2:
	sw $t0,mis2_pos# update mis1_pos in memory
# ------------------ #




# -------------------------------------------- UPDATE POSITIONS -------------------------------------------------- #

# -------------------------------------------- RENDERING -------------------------------------------------- #

# algorithm to render player ship:
# --------------- #
	jal rendering_ship
# -------------------- #

# algorithm to render astr1
# ------------------ #

	jal rendering_ast1 # function call to render all asrt1
# ----------------- #


# algorithm to render astr2
# ------------------ #
lw $t1, mis1_pos # load value of mis1_pos
addi $t1, $t1,BASE_ADDRESS# get absolute position of where ast2 starts

li $t8,8 # loop variable, x, 8/4+1 = 3 pixels in ast2
	render_mis1:
	#getting pixel color
		lw $t5, mis1_colors($t8)# load color into $t5
	# getting pixel address
		lw $t0, mis1_coord($t8) # load relative address of xth pixel of ast2
		add $t0,$t0,$t1# now $t0 is absolute address of xth pixel
	# check for collision:
		lw $t2, 0($t0) # pixel color to check
		# checks if cuurent color is ship colors: 0x263238,0x4a148c,0xd50000
		beq $t2,  0x263238, mis1_col_detected
		beq $t2, 0x4a148c, mis1_col_detected
		beq $t2, 0xd50000, mis1_col_detected
		j mis1_col_end
	mis1_col_detected:
		li damaged, 1 # damage done by ast1
		li $t2,0 # reset position ast1
		sw $t2, mis1_pos($zero)
		j mis1_render_end # stop rendering 
	mis1_col_end:
	# displaying pixel color
		sw $t5, 0($t0) # store colour on framebuffer
	
	addi $t8,$t8,-4#decrement counter
	bgez $t8, render_mis1#check if counter x != 0, then loop
mis1_render_end:
# ----------------- #

# algorithm to render mis2
# ------------------ #
lw $t1, mis2_pos # load value of mis1_pos
addi $t1, $t1,BASE_ADDRESS# get absolute position of where ast2 starts

li $t8,8 # loop variable, x, 8/4+1 = 3 pixels in mis2
	render_mis2:
	#getting pixel color
		lw $t5, mis2_colors($t8)# load color into $t5
	# getting pixel address
		lw $t0, mis2_coord($t8) # load relative address of xth pixel of mis2
		add $t0,$t0,$t1# now $t0 is absolute address of xth pixel
	# check for collision:
		lw $t2, 0($t0) # pixel color to check
		# checks if cuurent color is ship colors: 0x263238,0x4a148c,0xd50000
		beq $t2,  0x263238, mis2_col_detected
		beq $t2, 0x4a148c, mis2_col_detected
		beq $t2, 0xd50000, mis2_col_detected
		j mis2_col_end
	mis2_col_detected:
		li damaged, 1 # damage done by ast1
		li $t2,0 # reset position ast1
		sw $t2, mis2_pos($zero)
		j mis2_render_end # stop rendering 
	mis2_col_end:
	# displaying pixel color
		sw $t5, 0($t0) # store colour on framebuffer
	
	addi $t8,$t8,-4#decrement counter
	bgez $t8, render_mis2#check if counter x != 0, then loop
mis2_render_end:
# ----------------- #





# algorithm to render the Healing kit
# ----------------- #
lw $t0, heal_start # loads value of heal_start
bne $t0,1,heal_skip # skip rendering if heal_start != 1 

lw $t1, heal_pos # load value of  heal_pos
addi $t1, $t1,BASE_ADDRESS# get absolute position of where heal_pos starts


li $t8,32 # loop variable, x, 32/4+1 = 9 pixels in the heal kit
render_heal:
#getting pixel color
	lw $t5, heal_colors($t8) # load xth color into $t5
# getting pixel address
	lw $t0, heal_coord($t8) # load relative address of xth pixel of ast1
	add $t0,$t0,$t1# now $t0 is absolute address of xth pixel
# check for collision:
	lw $t2, 0($t0) # pixel color to check
	# checks if cuurent color is ship colors: 0x263238,0x4a148c,0xd50000
	beq $t2,  0x263238, heal_col_detected
	beq $t2, 0x4a148c, heal_col_detected
	beq $t2, 0xd50000, heal_col_detected
	j heal_col_end
heal_col_detected:
	li $t2,2 # load value 2 
	sw $t2, heal_start # heal no longer available
	j heal_render_end # stop rendering 
heal_col_end:
# displaying pixel color
	sw $t5, 0($t0) # store colour on framebuffer
addi $t8,$t8,-4#decrement counter
bgez $t8, render_heal#check if counter x != 0, then loop


heal_render_end:


heal_skip:
# ---------------- #


# render health bar
# ----------------#
bne damaged,1,no_damage2 #check if damage is done
	lw $t0, health($zero) #loads current health bar
	sw $zero, BASE_ADDRESS($t0) # blacks out a health
	addi $t0,$t0,-4 # decrements the health
	sw $t0, health # updates the new health
	beq $t0, 3904, game_over # checks if health is done
	li damaged,0
no_damage2:

lw $t0, heal_start
bne $t0,2,no_heal
	# making health bar full 
		li $t9, 3960 # till end
		lw $t8, health # start from health
		li $t0 0x00ff00 #green
	health_bar2:
		sw $t0, BASE_ADDRESS($t8) 
		addi $t8,$t8,4
		li $v0, 32 #loading sleep service
		li $a0, 80 # Wait
		syscall
		ble $t8,$t9,health_bar2
	li $t0, 3960
	sw $t0, health # update health to full
	li $t0,3
	sw $t0,heal_start
no_heal:

# ----------------#


# -------------------------------------------- RENDERING END -------------------------------------------------- #

# sleep stuff
	li $v0, 32 #loading sleep service
	li $a0, SLEEP # Wait
	syscall

# timer stuff:
# ------------ #
	addi timer,timer,1 # increment timer
	blt timer,LEVEL_2_LENGTH,level_2 # check if 60 frames have passed

	li timer, 0 # reset timer
	sw $zero, BASE_ADDRESS(timer_bar)# reduce timer on timer_bar
	addi timer_bar,timer_bar,-4 # decrement timer_bar address

	beq timer_bar,3840, done_level_2 # if all of timer bar is decremented, goto done_level_2
# ----------- #

j level_2

############# -------------------------------------------------------------------------- LEVEL 2 ENDS --------------------------------------------------------------------------------------- ###############

done_level_2:

game_over:


li $v0, 10 # terminate the program gracefully
syscall


# -------------------- FUCNTIONS ------------------- #

check_input: # void check_input(void)
	# recieve input asdw and update ship position( function )
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
	jr $ra
# ----------------- #

rendering_ship:
	# function  to render the ship
addi $t1, ship_pos,BASE_ADDRESS# get abs position of ship

# positions to clear 0,4,8,12,     136,140,144,     256,260,264,268,272,276
# ship colors: 0x263238,0x263238,0x263238,0x4a148c,     0x4a148c,0x4a148c,0x2195f3,     0x263238,0x4a148c,0x4a148c,0x4a148c,0x4a148c,0xd50000
li $t0, 0x263238 #grey
sw $t0, 0($t1) # saving color in framebuffer
sw $t0, 4($t1)  # saving color in framebuffer
sw $t0, 8($t1)  # saving color in framebuffer
li $t0, 0x4a148c #purple
sw $t0, 12($t1)  # saving color in framebuffer

sw $t0, 136($t1) # saving color in framebuffer
sw $t0, 140($t1) # saving color in framebuffer
li $t0, 0x2195f3 #blue
sw $t0, 144($t1) # saving color in framebuffer

li $t0, 0x263238 # grey
sw $t0, 256($t1) # saving color in framebuffer
li $t0, 0x4a148c # purple
sw $t0, 260($t1) # saving color in framebuffer
sw $t0, 264($t1) # saving color in framebuffer
sw $t0, 268($t1) # saving color in framebuffer
	sw $t0, 272($t1) # saving color in framebuffer
	li $t0, 0xd50000 # red
	sw $t0, 276($t1)

	jr $ra
# ----------------- #


# ------- update ast1_pos ----------#
# this astroid can only move left at speed 1 pixel, from pixel 0-26
updating_ast1 : # function void updating_ast1(void)
	li $t9,12 # loop vairable over the 4 ast1's

	update_next_ast1:

		la $t0, ast1_pos($t9) # address to ast1_pos
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
			sw $t0,ast1_pos($t9) # update ast1_pos in memory
	
	addi $t9,$t9,-4
	bgez $t9,update_next_ast1
	
	jr $ra
# ------------------ #


# algorithm to render astr1
# ------------------ #
rendering_ast1:
	li $t9,12 # loop vairable over the 4 ast1's

	render_next_ast1:
	la $t1, ast1_pos($t9) # load adress to ast1_pos
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
		sw $t2, ast1_pos($t9)
		j ast1_render_end # stop rendering 
	ast1_col_end:
	# displaying pixel color
		sw $t5, 0($t0) # store colour on framebuffer
		addi $t8,$t8,-4#decrement counter
		bgez $t8, render_ast1#check if counter x != 0, then loop
	ast1_render_end:

	addi $t9,$t9,-4
	bgez $t9,render_next_ast1
	
	jr $ra
# ----------------- #
