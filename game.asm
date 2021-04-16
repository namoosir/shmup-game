#####################################################################
#
# CSCB58 Winter2021 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Nazmus Saqeeb, 1006306007, saqeebna
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8 
# - Unit height in pixels: 8 
# - Display width in pixels: 256 
# - Display height in pixels: 256 
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission
# - Milestone 4
#
# Which approved features have been implemented for milestone 4?
# (See the assignment handout for the list of additional features)
# 1. Smooth Graphics
# 2. Increase in difficulty
# 3. Scoring system
#
# Link to video demonstration for final submission:
# - https://play.library.utoronto.ca/a1e079871fd09a28fdf72a2854c18247
#
# Are you OK with us sharing the video with people outside course staff?
# - yes, and please share this project githublink as well! https://github.com/namoosir/shmup-game
#
# Any additional information that the TA needs to know:
# - None
######################################################################

.eqv	BASE_ADDRESS	0x10008000
.eqv	SLEEP_TIME	50
.eqv	SHIP_LEN	80
.eqv	OBS1_LEN	40

.data
# miscellaneous
lives:		.word	3

# ship
ship:		.word	0, 0xffffff, -124, 0xffffff, 128, 0x5c8ab5, 4, 0x5c8ab5, 4, 0xffffff, 116, 0xffffff, 4, 0x5c8ab5, 4, 0x5c8ab5, 4, 0xffffff, 120, 0xffffff
currShipLoc:	.word	1936
newShipLoc:	.word	1936

# obstacle 1
obs1:		.word	0, 0x9a9fb3, -124, 0x9a9fb3, 128, 0x58595e, 4, 0x9a9fb3, 124, 0x9a9fb3
currObs1Loc:	.word	0
newObs1Loc:	.word	0

# obstacle 2
currObs2Loc: 	.word	0
newObs2Loc: 	.word	0

# obstacle 3
currObs3Loc: 	.word	0
newObs3Loc: 	.word 	0

.text

.globl main

main:
	li $t0, BASE_ADDRESS	# get base address of display
	li $t1, 0		# index
	li $t2, 4		# increment
	li $t3, 4096		# total length
	li $s1, SLEEP_TIME	# get the sleep time
	li $s2, 0		# frame counter
	li $s3, 0		# score counter
	
clear:
	add $t4, $t0, $t1	# calculate offset
	sw $0, ($t4)		# store 0 into array
	
	add $t1, $t1, $t2	# update index
	bne $t3, $t1, clear	# looping condition
	
	la $s0, lives		# get address of lives
	lw $s0, ($s0)		# get value of lives
	
main_loop:
	jal keypress_check	# check for keypresses and update ship location
	jal obstacles		# update the location of the obstacles
	
	jal collision_check	# check for collisions, returns 1 if collided, 0 otherwise in $v0
	
	sub $s0, $s0, $v0	# update number of lives
	
	move $a1, $v0		# update parameter of eraseall
	jal eraseall		# erase everything on the screen
	
	move $a1, $s0		# update parameter of draw
	jal draw		# draw everything
	
	
	beq $0, $s0, end	# lives are at 0, game over
	
	li $t9, 100		
	beq $t9, $s2, inDif	# every 100 frames, increase difficulty
	
	li $v0, 32		# sleep for sleep time
	move $a0, $s1
	syscall
	
	addi $s2, $s2, 1
	addi $s3, $s3, 1
	
	j main_loop		# loop back
	
inDif:
	li $s2, 0		# reset frame counter
	subi $s1, $s1, 2
	
	li $v0, 32		# sleep for sleep time
	move $a0, $s1
	syscall
	
	j main_loop		# loop back
	

######################################################################
# Functions Begin
######################################################################

# updates location of obstacles
obstacles:	
	la $t0, currObs1Loc	# get current location of obstacle 1
	lw $t1, ($t0)
	
	li $t2, 128		# divide and get the remainder
	div $t1, $t2
	mfhi $t3
	
	beq $t3, $0, getNew1	# obstacle out of screen, generate new one
	
	subi $t1, $t1, 4	# update the current location
	
	la $t2, newObs1Loc	# get new location of obstacle 1
	sw $t1, ($t2)		# set new location to the updated current location
	j  check2		# check next obstacle
	
# generate new obstacles	
getNew1:
	li $v0, 42		# randomly generate location of obstacle 1
	li $a0, 0
	li $a1, 28
	syscall
	
	move $t5, $a0		# process the number so it is a proper location
	addi $t5, $t5, 2
	li $t2, 128
	mult $t5, $t2
	mflo $t5
	subi $t5, $t5, 12
	
	la $t2, newObs1Loc	# set the new location
	sw $t5, ($t2)

check2:
	la $t0, currObs2Loc	# get current location of obstacle 2
	lw $t1, ($t0)
	
	li $t2, 128		# divide and get the remainder
	div $t1, $t2
	mfhi $t3
	
	beq $t3, $0, getNew2	# obstacle out of screen, generate new one
	li $t9, 124
	beq $t3, $t9, getNew2	# obstacle out of screen, generate new one
	
	subi $t1, $t1, 8	# update the current location
	
	la $t2, newObs2Loc	# get new location of obstacle 2
	sw $t1, ($t2)		# set new location to the updated current location
	j  check3		# check next obstacle

getNew2:
	li $v0, 42		# randomly generate location of obstacle 2
	li $a0, 0
	li $a1, 28
	syscall
	
	move $t5, $a0		# process the number so it is a proper location
	addi $t5, $t5, 2
	li $t2, 128
	mult $t5, $t2
	mflo $t5
	subi $t5, $t5, 12
	
	la $t2, newObs2Loc	# set the new location
	sw $t5, ($t2)
	
check3:
	la $t0, currObs3Loc	# get current location of obstacle 3
	lw $t1, ($t0)
	
	li $t2, 128		# divide and get the remainder
	div $t1, $t2
	mfhi $t3
	
	beq $t3, $0, getNew3	# obstacle out of screen, generate new one
	
	subi $t1, $t1, 4	# update the current location
	
	la $t2, newObs3Loc	# get new location of obstacle 2
	sw $t1, ($t2)		# set new location to the updated current location
	j  returnObstacles	# return

getNew3:
	li $v0, 42		# randomly generate location of obstacle 1
	li $a0, 0
	li $a1, 28
	syscall
	
	move $t5, $a0		# process the number so it is a proper location
	addi $t5, $t5, 2
	li $t2, 128
	mult $t5, $t2
	mflo $t5
	subi $t5, $t5, 12
	
	la $t2, newObs3Loc	# set the new location
	sw $t5, ($t2)

returnObstacles:	
	jr $ra			# return

# checks if a key has been pressed
keypress_check:
	li $t9, 0xffff0000		# where keypresses are stored
	lw $t8, 0($t9)			# get the value
	beq $t8, 1, keypress		# go to function that will check which key was pressed
	jr $ra				# return

# checks which key was pressed
keypress:
	lw $t4, 4($t9)
	beq $t4, 0x61, respond_to_a	# a was pressed
	beq $t4, 0x64, respond_to_d	# d was pressed
	beq $t4, 0x73, respond_to_s	# s was pressed
	beq $t4, 0x77, respond_to_w	# w was pressed
	beq $t4, 0x70, respond_to_p	# p was pressed
	jr $ra				# return

# updates location of ship if a is pressed
respond_to_a:
	la $t0, currShipLoc	# get current location of ship
	lw $t1, ($t0)
	
	li $t2, 128		# divide and get the remainder
	div $t1, $t2
	mfhi $t3
	
	beq $t3, $0, a_return	# ship at left edge of screen
	
	subi $t1, $t1, 4	# update the location of ship
	la $t0, newShipLoc
	sw $t1, ($t0)

# returns from a
a_return:
	jr $ra			# return

# updates location of ship if d is pressed	
respond_to_d:
	la $t0, currShipLoc	# get current location of ship
	lw $t1, ($t0)
	
	addi $t4, $t1, 16	# add 16 to get offset
	li $t2, 128		# divide and get the remainder
	div $t4, $t2
	mfhi $t3
	
	beq $t3, $0, d_return	# ship at right edge of screen
	
	addi $t1, $t1, 4
	la $t0, newShipLoc	# update the new location of the ship
	sw $t1, ($t0)

# returns from d
d_return:
	jr $ra			# return

# updates location of ship if s is pressed	
respond_to_s:
	la $t0, currShipLoc	# get current location of ship
	lw $t1, ($t0)
	
	addi $t4, $t1, 260	# add 260 to get offset
	
	li $t3, 3968
	bge $t4, $t3, s_return	# ship at bottom edge of screen
	
	addi $t1, $t1, 128
	la $t0, newShipLoc	# update the new location of the ship
	sw $t1, ($t0)

# returns from s
s_return:
	jr $ra			# return
	
# updates location of ship if w is pressed
respond_to_w:
	la $t0, currShipLoc	# get current location of ship
	lw $t1, ($t0)
	
	subi $t4, $t1, 124	# subtract 124 to get offset
	
	li $t3, 124
	ble $t4, $t3, w_return	# ship at bottom edge of screen
	
	subi $t1, $t1, 128
	la $t0, newShipLoc	# update the new location of the ship
	sw $t1, ($t0)

# returns from w
w_return:
	jr $ra			# return
	

# updates location of ship if p is pressed
respond_to_p:
	j main

# checks for collisions, returns 1 if collided, 0 otherwise in $v0
collision_check:
	la $t0, newShipLoc	# get the ship location
	lw $t0, ($t0)
	la $t1, ship		# get the ship
	li $t2, SHIP_LEN	# get the ship length
	
	la $t3, newObs1Loc	# get obstacle 1 location
	lw $t3, ($t3)
	la $t4, obs1		# get the obstacle
	
	li $t5, 0		# index

# check if ship collided with obstacle 1
obs1ColLoop:
	add $t1, $t1, $t5	# calculate offset for array
	lw $t6, ($t1)		# get location of pixel of ship
	add $t6, $t6, $t0	# add offset
	
	lw $t7, ($t4)		# get location of pixel of obstacle
	add $t7, $t7, $t3	# add offset
	
	beq $t6, $t7, collided1	# collision occured
	
	lw $t8, 8($t4)		# get next pixel position
	add $t7, $t7, $t8	# add offset
	
	beq $t6, $t7, collided1	# collision occured
	
	lw $t8, 16($t4)		# get next pixel position
	add $t7, $t7, $t8	# add offset
	
	beq $t6, $t7, collided1	# collision occured
	
	lw $t8, 24($t4)		# get next pixel position
	add $t7, $t7, $t8	# add offset
	
	beq $t6, $t7, collided1	# collision occured
	
	lw $t8, 32($t4)		# get next pixel position
	add $t7, $t7, $t8	# add offset
	
	beq $t6, $t7, collided1	# collision occured
	
	addi $t5, $t5, 8		# update index
	bne $t5, $t2, obs1ColLoop	# looping condition
	
	
	la $t0, newShipLoc	# get the ship location
	lw $t0, ($t0)
	la $t1, ship		# get the ship
	li $t2, SHIP_LEN	# get the ship length
	
	la $t3, newObs2Loc	# get obstacle 2 location
	lw $t3, ($t3)
	la $t4, obs1		# get the obstacle
	
	li $t5, 0		# index
	
# check if ship collided with obstacle 1
obs2ColLoop:
	add $t1, $t1, $t5	# calculate offset for array
	lw $t6, ($t1)		# get location of pixel of ship
	add $t6, $t6, $t0	# add offset
	
	lw $t7, ($t4)		# get location of pixel of obstacle
	add $t7, $t7, $t3	# add offset
	
	beq $t6, $t7, collided2	# collision occured
	
	lw $t8, 8($t4)		# get next pixel position
	add $t7, $t7, $t8	# add offset
	
	beq $t6, $t7, collided2	# collision occured
	
	lw $t8, 16($t4)		# get next pixel position
	add $t7, $t7, $t8	# add offset
	
	beq $t6, $t7, collided2	# collision occured
	
	lw $t8, 24($t4)		# get next pixel position
	add $t7, $t7, $t8	# add offset
	
	beq $t6, $t7, collided2	# collision occured
	
	lw $t8, 32($t4)		# get next pixel position
	add $t7, $t7, $t8	# add offset
	
	beq $t6, $t7, collided2	# collision occured
	
	addi $t5, $t5, 8		# update index
	bne $t5, $t2, obs2ColLoop	# looping condition
	
	
	la $t0, newShipLoc	# get the ship location
	lw $t0, ($t0)
	la $t1, ship		# get the ship
	li $t2, SHIP_LEN	# get the ship length
	
	la $t3, newObs3Loc	# get obstacle 3 location
	lw $t3, ($t3)
	la $t4, obs1		# get the obstacle
	
	li $t5, 0		# index
	
# check if ship collided with obstacle 1
obs3ColLoop:
	add $t1, $t1, $t5	# calculate offset for array
	lw $t6, ($t1)		# get location of pixel of ship
	add $t6, $t6, $t0	# add offset
	
	lw $t7, ($t4)		# get location of pixel of obstacle
	add $t7, $t7, $t3	# add offset
	
	beq $t6, $t7, collided3	# collision occured
	
	lw $t8, 8($t4)		# get next pixel position
	add $t7, $t7, $t8	# add offset
	
	beq $t6, $t7, collided3	# collision occured
	
	lw $t8, 16($t4)		# get next pixel position
	add $t7, $t7, $t8	# add offset
	
	beq $t6, $t7, collided3	# collision occured
	
	lw $t8, 24($t4)		# get next pixel position
	add $t7, $t7, $t8	# add offset
	
	beq $t6, $t7, collided3	# collision occured
	
	lw $t8, 32($t4)		# get next pixel position
	add $t7, $t7, $t8	# add offset
	
	beq $t6, $t7, collided3	# collision occured
	
	addi $t5, $t5, 8		# update index
	bne $t5, $t2, obs3ColLoop	# looping condition
	
	li $v0, 0
	jr $ra 			# return no collision
	
collided1:	
	li $v0, 42		# randomly generate location of obstacle 1
	li $a0, 0
	li $a1, 28
	syscall
	
	move $t5, $a0		# process the number so it is a proper location
	addi $t5, $t5, 2
	li $t2, 128
	mult $t5, $t2
	mflo $t5
	subi $t5, $t5, 12
	
	la $t2, newObs1Loc	# set the new location
	sw $t5, ($t2)
	
	li $t6, 0xff0000	# get the color red
	li $t7, BASE_ADDRESS	# get the base address
	sw $t6, ($t7)		# paint the corners red
	sw $t6, 4($t7)
	sw $t6, 128($t7)
	sw $t6, 120($t7)
	sw $t6, 124($t7)
	sw $t6, 252($t7)
	sw $t6, 3840($t7)
	sw $t6, 3968($t7)
	sw $t6, 3972($t7)
	sw $t6, 3964($t7)
	sw $t6, 4088($t7)
	sw $t6, 4092($t7)
	
	li $v0, 1		# return 1 since collision happened
	jr $ra			# return
	
collided2:	
	li $v0, 42		# randomly generate location of obstacle 2
	li $a0, 0
	li $a1, 28
	syscall
	
	move $t5, $a0		# process the number so it is a proper location
	addi $t5, $t5, 2
	li $t2, 128
	mult $t5, $t2
	mflo $t5
	subi $t5, $t5, 12
	
	la $t2, newObs2Loc	# set the new location
	sw $t5, ($t2)
	
	li $t6, 0xff0000	# get the color red
	li $t7, BASE_ADDRESS	# get the base address
	sw $t6, ($t7)		# paint the corners red
	sw $t6, 4($t7)
	sw $t6, 128($t7)
	sw $t6, 120($t7)
	sw $t6, 124($t7)
	sw $t6, 252($t7)
	sw $t6, 3840($t7)
	sw $t6, 3968($t7)
	sw $t6, 3972($t7)
	sw $t6, 3964($t7)
	sw $t6, 4088($t7)
	sw $t6, 4092($t7)
	
	li $v0, 1		# return 1 since collision happened
	jr $ra 			# return
	
collided3:
	li $v0, 42		# randomly generate location of obstacle 1
	li $a0, 0
	li $a1, 28
	syscall
	
	move $t5, $a0		# process the number so it is a proper location
	addi $t5, $t5, 2
	li $t2, 128
	mult $t5, $t2
	mflo $t5
	subi $t5, $t5, 12
	
	la $t2, newObs3Loc	# set the new location
	sw $t5, ($t2)
	
	li $t6, 0xff0000	# get the color red
	li $t7, BASE_ADDRESS	# get the base address
	sw $t6, ($t7)		# paint the corners red
	sw $t6, 4($t7)
	sw $t6, 128($t7)
	sw $t6, 120($t7)
	sw $t6, 124($t7)
	sw $t6, 252($t7)
	sw $t6, 3840($t7)
	sw $t6, 3968($t7)
	sw $t6, 3972($t7)
	sw $t6, 3964($t7)
	sw $t6, 4088($t7)
	sw $t6, 4092($t7)
	
	li $v0, 1		# return 1 since collision happened
	jr $ra			# return


# erase everything on the screen
eraseall:
	li $t0, BASE_ADDRESS	# get base address of display
	
	bne $0, $a1, noEraseCorner
	
	sw $0, ($t0)
	sw $0, 4($t0)
	sw $0, 128($t0)
	sw $0, 120($t0)
	sw $0, 124($t0)
	sw $0, 252($t0)
	sw $0, 3840($t0)
	sw $0, 3968($t0)
	sw $0, 3972($t0)
	sw $0, 3964($t0)
	sw $0, 4088($t0)
	sw $0, 4092($t0)

noEraseCorner:
	li $t1, 0		# index
	
	la $t2, currShipLoc	# get current ship location
	lw $t2, ($t2)
	la $t9, newShipLoc	# get new ship location
	lw $t9, ($t9)
	
	beq $t2, $t9, noShipErase	# no need to erase ship if it is in the same position
	
	add $t5, $t0, $t2	# calculate offset to erase ship
	
	la $t3, ship		# get address of ship
	li $t4, SHIP_LEN	# get length of ship array
	

# erases the ship
eraseShip:
	add $t6, $t1, $t3	# calculate offset
	lw $t7, ($t6)		# get pixel location
	
	add $t5, $t5, $t7	# get offset for pixel array
	sw $0, ($t5)		# store 0 into array to erase
	
	addi $t1, $t1, 8		# update index
	bne $t4, $t1, eraseShip		# looping condition

# continue erasing other things
noShipErase:
	la $t1, currObs1Loc	# get current location of obstacle 1
	lw $t1, ($t1)
	la $t2, obs1		# get obstacle 1
	
	add $t3, $t1, $t0	# calculate offset to erase obstacle 1
	li $t4, OBS1_LEN	# get length of obs1
	
	li $t5, 0		# index

# erase obstacle 1 COULD HAVE BUG SINCE CURRENT LOCATION STARTS OFF AT 0
eraseObs1:
	add $t6, $t5, $t2	# calculate offset
	lw $t7, ($t6)		# get pixel location
	
	add $t3, $t3, $t7	# get offset for pixel array
	sw $0, ($t3)		# store 0 to erase
	
	addi $t5, $t5, 8		# update index
	bne $t4, $t5, eraseObs1		# looping condition
	
# start to erase obstacle 2
	
	la $t1, currObs2Loc	# get current location of obstacle 2
	lw $t1, ($t1)
	la $t2, obs1		# get obstacle 1
	
	add $t3, $t1, $t0	# calculate offset to erase obstacle 2
	li $t4, OBS1_LEN	# get length of obs1
	
	li $t5, 0		# index

# erase obstacle 2 COULD HAVE BUG SINCE CURRENT LOCATION STARTS OFF AT 0
eraseObs2:
	add $t6, $t5, $t2	# calculate offset
	lw $t7, ($t6)		# get pixel location
	
	add $t3, $t3, $t7	# get offset for pixel array
	sw $0, ($t3)		# store 0 to erase
	
	addi $t5, $t5, 8		# update index
	bne $t4, $t5, eraseObs2		# looping condition

# start to erase obstacle 3
	la $t1, currObs3Loc	# get current location of obstacle 3
	lw $t1, ($t1)
	la $t2, obs1		# get obstacle 1
	
	add $t3, $t1, $t0	# calculate offset to erase obstacle 3
	li $t4, OBS1_LEN	# get length of obs1
	
	li $t5, 0		# index

# erase obstacle 1 COULD HAVE BUG SINCE CURRENT LOCATION STARTS OFF AT 0
eraseObs3:
	add $t6, $t5, $t2	# calculate offset
	lw $t7, ($t6)		# get pixel location
	
	add $t3, $t3, $t7	# get offset for pixel array
	sw $0, ($t3)		# store 0 to erase
	
	addi $t5, $t5, 8		# update index
	bne $t4, $t5, eraseObs3		# looping condition
	
	li $t0, BASE_ADDRESS	# get base address
	
	sw $0, 3896($t0)	# erase the health bar
	sw $0, 3900($t0)
	sw $0, 3904($t0)
	
	jr $ra			# return
	
# draw function
draw:
	li $t0, BASE_ADDRESS	# get the base address
	la $t1, newShipLoc	# get the new location of the ship
	lw $t2, ($t1)
	
	la $t3, currShipLoc	# get current location of ship
	sw $t2, ($t3)		# set current location of ship to be the new location of ship
	
	add $t0, $t0, $t2	# calculate offset
	
	li $t2, SHIP_LEN	# get length of ship array
	la $t4, ship		# get address of ship array
	
	li $t7, 0		# set index

# draws the ship
shipLoop:
	add $t8, $t4, $t7	# offset for ship array
	lw $t5, ($t8)		# location of pixel
	lw $t6, 4($t8)		# color of pixel
	
	add $t0, $t0, $t5	# calculate offset for pixel array
	sw $t6, ($t0)		# set color of pixel
	
	addi $t7, $t7, 8	# update index
	bne $t7, $t2, shipLoop	# looping condition	

# start drawing obstacle 1

	li $t0, BASE_ADDRESS	# get the base address
	la $t1, newObs1Loc	# get the new location of the obstacle
	lw $t2, ($t1)
	
	la $t3, currObs1Loc	# get the current location of the obstacle
	sw $t2, ($t3)		# set current location of the obstacle to be the new location of the obstacle
	
	add $t4, $t0, $t2	# calculate offset
	
	la $t5, obs1		# get obstacle 1
	li $t6, OBS1_LEN	# get the length of obstacle 1 array
	
	li $t7, 0		# set index
	
obs1Loop:
	add $t8, $t5, $t7	# offset for obstacle 1 array
	lw $t9, ($t8)		# location of pixel
	lw $t1, 4($t8)		# color of pixel
	
	add $t4, $t4, $t9	# calculate offset for pixel array
	sw $t1, ($t4)		# set color of pixel
	
	addi $t7, $t7, 8	# update index
	bne $t7, $t6, obs1Loop	# looping condition
	
# start drawing obstacle 2

	li $t0, BASE_ADDRESS	# get the base address
	la $t1, newObs2Loc	# get the new location of the obstacle
	lw $t2, ($t1)
	
	la $t3, currObs2Loc	# get the current location of the obstacle
	sw $t2, ($t3)		# set current location of the obstacle to be the new location of the obstacle
	
	add $t4, $t0, $t2	# calculate offset
	
	la $t5, obs1		# get obstacle 1
	li $t6, OBS1_LEN	# get the length of obstacle 1 array
	
	li $t7, 0		# set index
	
obs2Loop:
	add $t8, $t5, $t7	# offset for obstacle 1 array
	lw $t9, ($t8)		# location of pixel
	lw $t1, 4($t8)		# color of pixel
	
	add $t4, $t4, $t9	# calculate offset for pixel array
	sw $t1, ($t4)		# set color of pixel
	
	addi $t7, $t7, 8	# update index
	bne $t7, $t6, obs2Loop	# looping condition
	
# start drawing obstacle 3
	
	li $t0, BASE_ADDRESS	# get the base address
	la $t1, newObs3Loc	# get the new location of the obstacle
	lw $t2, ($t1)
	
	la $t3, currObs3Loc	# get the current location of the obstacle
	sw $t2, ($t3)		# set current location of the obstacle to be the new location of the obstacle
	
	add $t4, $t0, $t2	# calculate offset
	
	la $t5, obs1		# get obstacle 1
	li $t6, OBS1_LEN	# get the length of obstacle 1 array
	
	li $t7, 0		# set index
	
obs3Loop:
	add $t8, $t5, $t7	# offset for obstacle 1 array
	lw $t9, ($t8)		# location of pixel
	lw $t1, 4($t8)		# color of pixel
	
	add $t4, $t4, $t9	# calculate offset for pixel array
	sw $t1, ($t4)		# set color of pixel
	
	addi $t7, $t7, 8	# update index
	bne $t7, $t6, obs3Loop	# looping condition
	
	
	li $t7, 3
	beq $a1, $t7, health3	# if health is 3
	
	li $t7, 2
	beq $a1, $t7, health2	# if health is 2
	
	li $t7, 1
	beq $a1, $t7, health1	# if health is 1
	
	j returnDraw		# return
	
health3:
	li $t0, BASE_ADDRESS	# get base address
	li $t1, 0x00ff00	# get green color
	
	sw $t1, 3896($t0)
	sw $t1, 3900($t0)
	sw $t1, 3904($t0)
	j returnDraw
	
health2:
	li $t0, BASE_ADDRESS	# get base address
	li $t1, 0x00ff00	# get green color
	
	sw $t1, 3896($t0)
	sw $t1, 3900($t0)
	j returnDraw
	
health1:
	li $t0, BASE_ADDRESS	# get base address
	li $t1, 0x00ff00	# get green color
	
	sw $t1, 3896($t0)
	j returnDraw
	
returnDraw:	
	jr $ra			# return

	

# game over
end:
	li $a1, 0		# update parameter of eraseall
	jal eraseall		# erase everything on the screen
	
	li $t0, BASE_ADDRESS	# get base address of display
	la $t2, currShipLoc	# get current ship location
	lw $t2, ($t2)
	add $t5, $t0, $t2	# calculate offset to erase ship
	la $t3, ship		# get address of ship
	li $t4, SHIP_LEN	# get length of ship array
	li $t1, 0		# index

# erases the ship
eraseShipEnd:
	add $t6, $t1, $t3	# calculate offset
	lw $t7, ($t6)		# get pixel location
	
	add $t5, $t5, $t7	# get offset for pixel array
	sw $0, ($t5)		# store 0 into array to erase
	
	addi $t1, $t1, 8		# update index
	bne $t4, $t1, eraseShipEnd	# looping condition
	
	# display game over sign
	li $t9, 0xffffff
	
	# G
	sw $t9, 1048($t0)
	sw $t9, 1052($t0)
	sw $t9, 1056($t0)
	sw $t9, 1172($t0)
	sw $t9, 1300($t0)
	sw $t9, 1428($t0)
	sw $t9, 1560($t0)
	sw $t9, 1564($t0)
	sw $t9, 1568($t0)
	sw $t9, 1440($t0)
	sw $t9, 1312($t0)
	sw $t9, 1308($t0)
	
	# A
	sw $t9, 1192($t0)
	sw $t9, 1320($t0)
	sw $t9, 1448($t0)
	sw $t9, 1576($t0)
	sw $t9, 1068($t0)
	sw $t9, 1072($t0)
	sw $t9, 1204($t0)
	sw $t9, 1332($t0)
	sw $t9, 1460($t0)
	sw $t9, 1588($t0)
	sw $t9, 1324($t0)
	sw $t9, 1328($t0)
	
	# M
	sw $t9, 1084($t0)
	sw $t9, 1212($t0)
	sw $t9, 1340($t0)
	sw $t9, 1468($t0)
	sw $t9, 1596($t0)
	sw $t9, 1216($t0)
	sw $t9, 1348($t0)
	sw $t9, 1224($t0)
	sw $t9, 1100($t0)
	sw $t9, 1228($t0)
	sw $t9, 1356($t0)
	sw $t9, 1484($t0)
	sw $t9, 1612($t0)
	
	# E
	sw $t9, 1108($t0)
	sw $t9, 1236($t0)
	sw $t9, 1364($t0)
	sw $t9, 1492($t0)
	sw $t9, 1620($t0)
	sw $t9, 1112($t0)
	sw $t9, 1116($t0)
	sw $t9, 1120($t0)
	sw $t9, 1368($t0)
	sw $t9, 1372($t0)
	sw $t9, 1624($t0)
	sw $t9, 1628($t0)
	sw $t9, 1632($t0)
	
	# O
	sw $t9, 1940($t0)
	sw $t9, 2068($t0)
	sw $t9, 2196($t0)
	sw $t9, 1816($t0)
	sw $t9, 1820($t0)
	sw $t9, 1952($t0)
	sw $t9, 2080($t0)
	sw $t9, 2208($t0)
	sw $t9, 2328($t0)
	sw $t9, 2332($t0)
	
	# V
	sw $t9, 1832($t0)
	sw $t9, 1960($t0)
	sw $t9, 2088($t0)
	sw $t9, 2220($t0)
	sw $t9, 2352($t0)
	sw $t9, 2228($t0)
	sw $t9, 1848($t0)
	sw $t9, 1976($t0)
	sw $t9, 2104($t0)
	
	# 2nd E
	sw $t9, 1856($t0)
	sw $t9, 1984($t0)
	sw $t9, 2112($t0)
	sw $t9, 2240($t0)
	sw $t9, 2368($t0)
	sw $t9, 1860($t0)
	sw $t9, 1864($t0)
	sw $t9, 1868($t0)
	sw $t9, 2116($t0)
	sw $t9, 2120($t0)
	sw $t9, 2372($t0)
	sw $t9, 2376($t0)
	sw $t9, 2380($t0)
	
	# R
	sw $t9, 1876($t0)
	sw $t9, 2004($t0)
	sw $t9, 2132($t0)
	sw $t9, 2260($t0)
	sw $t9, 2388($t0)
	sw $t9, 1880($t0)
	sw $t9, 1884($t0)
	sw $t9, 2016($t0)
	sw $t9, 2136($t0)
	sw $t9, 2140($t0)
	sw $t9, 2144($t0)
	sw $t9, 2268($t0)
	sw $t9, 2400($t0)
	
	# S
	sw $t9, 2588($t0)
	sw $t9, 2712($t0)
	sw $t9, 2844($t0)
	sw $t9, 2968($t0)
	
	# C
	sw $t9, 2600($t0)
	sw $t9, 2724($t0)
	sw $t9, 2852($t0)
	sw $t9, 2984($t0)
	
	# O
	sw $t9, 2612($t0)
	sw $t9, 2736($t0)
	sw $t9, 2864($t0)
	sw $t9, 2744($t0)
	sw $t9, 2872($t0)
	sw $t9, 2996($t0)
	
	# R
	sw $t9, 2752($t0)
	sw $t9, 2880($t0)
	sw $t9, 3008($t0)
	sw $t9, 2628($t0)
	sw $t9, 2760($t0)
	sw $t9, 2884($t0)
	sw $t9, 3016($t0)
	
	# E
	sw $t9, 2768($t0)
	sw $t9, 2896($t0)
	sw $t9, 2644($t0)
	sw $t9, 2776($t0)
	sw $t9, 2900($t0)
	sw $t9, 3024($t0)
	sw $t9, 3156($t0)
	sw $t9, 3160($t0)
	
	# :
	sw $t9, 2784($t0)
	sw $t9, 3040($t0)
	
	# calculate score and display it
	li $t8, 100
	div $s3, $t8
	mflo $t7		# first digit
	mfhi $t6
	
	li $t8, 10
	div $t6, $t8
	mflo $t6		# second digit
	mfhi $t5		# last digit
	
	li $t3, 3352		# location to draw
	
	li $t4, 0
	beq $t4, $t7, zero1
	
	li $t4, 1
	beq $t4, $t7, one1
	
	li $t4, 2
	beq $t4, $t7, two1
	
	li $t4, 3
	beq $t4, $t7, three1
	
	li $t4, 4
	beq $t4, $t7, four1
	
	li $t4, 5
	beq $t4, $t7, five1
	
	li $t4, 6
	beq $t4, $t7, six1
	
	li $t4, 7
	beq $t4, $t7, seven1
	
	li $t4, 8
	beq $t4, $t7, eight1
	
	li $t4, 9
	beq $t4, $t7, nine1

# draw 0
zero1:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 4($t2)
	sw $t9, 8($t2)
	sw $t9, 128($t2)
	sw $t9, 136($t2)
	sw $t9, 256($t2)
	sw $t9, 264($t2)
	sw $t9, 384($t2)
	sw $t9, 388($t2)
	sw $t9, 392($t2)
	j secondNum
	
# draw 1
one1:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 128($t2)
	sw $t9, 256($t2)
	sw $t9, 384($t2)
	j secondNum
	
# draw 2
two1:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 4($t2)
	sw $t9, 8($t2)
	sw $t9, 136($t2)
	sw $t9, 260($t2)
	sw $t9, 384($t2)
	sw $t9, 388($t2)
	sw $t9, 392($t2)
	j secondNum

# draw 3
three1:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 132($t2)
	sw $t9, 256($t2)
	sw $t9, 388($t2)
	sw $t9, 512($t2)
	j secondNum
	
# draw 4
four1:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 128($t2)
	sw $t9, 256($t2)
	sw $t9, 260($t2)
	sw $t9, 8($t2)
	sw $t9, 136($t2)
	sw $t9, 264($t2)
	sw $t9, 392($t2)
	j secondNum
	
# draw 5
five1:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 128($t2)
	sw $t9, 260($t2)
	sw $t9, 4($t2)
	sw $t9, 8($t2)
	sw $t9, 392($t2)
	sw $t9, 516($t2)
	sw $t9, 512($t2)
	j secondNum
	
# draw 6
six1:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 4($t2)
	sw $t9, 8($t2)
	sw $t9, 128($t2)
	sw $t9, 256($t2)
	sw $t9, 260($t2)
	sw $t9, 264($t2)
	sw $t9, 384($t2)
	sw $t9, 392($t2)
	sw $t9, 512($t2)
	sw $t9, 516($t2)
	sw $t9, 520($t2)
	j secondNum
	
# draw 7
seven1:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 4($t2)
	sw $t9, 8($t2)
	sw $t9, 136($t2)
	sw $t9, 260($t2)
	sw $t9, 384($t2)
	j secondNum
	
# draw 8
eight1:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 4($t2)
	sw $t9, 8($t2)
	sw $t9, 128($t2)
	sw $t9, 136($t2)
	sw $t9, 256($t2)
	sw $t9, 260($t2)
	sw $t9, 264($t2)
	sw $t9, 384($t2)
	sw $t9, 392($t2)
	sw $t9, 512($t2)
	sw $t9, 516($t2)
	sw $t9, 520($t2)
	j secondNum
	
# draw 9
nine1:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 4($t2)
	sw $t9, 8($t2)
	sw $t9, 128($t2)
	sw $t9, 136($t2)
	sw $t9, 256($t2)
	sw $t9, 260($t2)
	sw $t9, 264($t2)
	sw $t9, 392($t2)
	sw $t9, 512($t2)
	sw $t9, 516($t2)
	sw $t9, 520($t2)
	j secondNum

	
secondNum:
	li $t3, 3368		# location to draw
	
	li $t4, 0
	beq $t4, $t6, zero2
	
	li $t4, 1
	beq $t4, $t6, one2
	
	li $t4, 2
	beq $t4, $t6, two2
	
	li $t4, 3
	beq $t4, $t6, three2
	
	li $t4, 4
	beq $t4, $t6, four2
	
	li $t4, 5
	beq $t4, $t6, five2
	
	li $t4, 6
	beq $t4, $t6, six2
	
	li $t4, 7
	beq $t4, $t6, seven2
	
	li $t4, 8
	beq $t4, $t6, eight2
	
	li $t4, 9
	beq $t4, $t6, nine2

# draw 0
zero2:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 4($t2)
	sw $t9, 8($t2)
	sw $t9, 128($t2)
	sw $t9, 136($t2)
	sw $t9, 256($t2)
	sw $t9, 264($t2)
	sw $t9, 384($t2)
	sw $t9, 388($t2)
	sw $t9, 392($t2)
	j thirdNum
	
# draw 1
one2:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 128($t2)
	sw $t9, 256($t2)
	sw $t9, 384($t2)
	j thirdNum
	
# draw 2
two2:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 4($t2)
	sw $t9, 8($t2)
	sw $t9, 136($t2)
	sw $t9, 260($t2)
	sw $t9, 384($t2)
	sw $t9, 388($t2)
	sw $t9, 392($t2)
	j thirdNum

# draw 3
three2:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 132($t2)
	sw $t9, 256($t2)
	sw $t9, 388($t2)
	sw $t9, 512($t2)
	j thirdNum
	
# draw 4
four2:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 128($t2)
	sw $t9, 256($t2)
	sw $t9, 260($t2)
	sw $t9, 8($t2)
	sw $t9, 136($t2)
	sw $t9, 264($t2)
	sw $t9, 392($t2)
	j thirdNum
	
# draw 5
five2:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 128($t2)
	sw $t9, 260($t2)
	sw $t9, 4($t2)
	sw $t9, 8($t2)
	sw $t9, 392($t2)
	sw $t9, 516($t2)
	sw $t9, 512($t2)
	j thirdNum
	
# draw 6
six2:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 4($t2)
	sw $t9, 8($t2)
	sw $t9, 128($t2)
	sw $t9, 256($t2)
	sw $t9, 260($t2)
	sw $t9, 264($t2)
	sw $t9, 384($t2)
	sw $t9, 392($t2)
	sw $t9, 512($t2)
	sw $t9, 516($t2)
	sw $t9, 520($t2)
	j thirdNum
	
# draw 7
seven2:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 4($t2)
	sw $t9, 8($t2)
	sw $t9, 136($t2)
	sw $t9, 260($t2)
	sw $t9, 384($t2)
	j thirdNum
	
# draw 8
eight2:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 4($t2)
	sw $t9, 8($t2)
	sw $t9, 128($t2)
	sw $t9, 136($t2)
	sw $t9, 256($t2)
	sw $t9, 260($t2)
	sw $t9, 264($t2)
	sw $t9, 384($t2)
	sw $t9, 392($t2)
	sw $t9, 512($t2)
	sw $t9, 516($t2)
	sw $t9, 520($t2)
	j thirdNum
	
# draw 9
nine2:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 4($t2)
	sw $t9, 8($t2)
	sw $t9, 128($t2)
	sw $t9, 136($t2)
	sw $t9, 256($t2)
	sw $t9, 260($t2)
	sw $t9, 264($t2)
	sw $t9, 392($t2)
	sw $t9, 512($t2)
	sw $t9, 516($t2)
	sw $t9, 520($t2)
	j thirdNum

thirdNum:
	li $t3, 3384		# location to draw
	
	li $t4, 0
	beq $t4, $t5, zero3
	
	li $t4, 1
	beq $t4, $t5, one3
	
	li $t4, 2
	beq $t4, $t5, two3
	
	li $t4, 3
	beq $t4, $t5, three3
	
	li $t4, 4
	beq $t4, $t5, four3
	
	li $t4, 5
	beq $t4, $t5, five3
	
	li $t4, 6
	beq $t4, $t5, six3
	
	li $t4, 7
	beq $t4, $t5, seven3
	
	li $t4, 8
	beq $t4, $t5, eight3
	
	li $t4, 9
	beq $t4, $t5, nine3
	
# draw 0
zero3:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 4($t2)
	sw $t9, 8($t2)
	sw $t9, 128($t2)
	sw $t9, 136($t2)
	sw $t9, 256($t2)
	sw $t9, 264($t2)
	sw $t9, 384($t2)
	sw $t9, 388($t2)
	sw $t9, 392($t2)
	j ending
	
# draw 1
one3:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 128($t2)
	sw $t9, 256($t2)
	sw $t9, 384($t2)
	j ending
	
# draw 2
two3:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 4($t2)
	sw $t9, 8($t2)
	sw $t9, 136($t2)
	sw $t9, 260($t2)
	sw $t9, 384($t2)
	sw $t9, 388($t2)
	sw $t9, 392($t2)
	j ending

# draw 3
three3:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 132($t2)
	sw $t9, 256($t2)
	sw $t9, 388($t2)
	sw $t9, 512($t2)
	j ending
	
# draw 4
four3:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 128($t2)
	sw $t9, 256($t2)
	sw $t9, 260($t2)
	sw $t9, 8($t2)
	sw $t9, 136($t2)
	sw $t9, 264($t2)
	sw $t9, 392($t2)
	j ending
	
# draw 5
five3:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 128($t2)
	sw $t9, 260($t2)
	sw $t9, 4($t2)
	sw $t9, 8($t2)
	sw $t9, 392($t2)
	sw $t9, 516($t2)
	sw $t9, 512($t2)
	j ending
	
# draw 6
six3:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 4($t2)
	sw $t9, 8($t2)
	sw $t9, 128($t2)
	sw $t9, 256($t2)
	sw $t9, 260($t2)
	sw $t9, 264($t2)
	sw $t9, 384($t2)
	sw $t9, 392($t2)
	sw $t9, 512($t2)
	sw $t9, 516($t2)
	sw $t9, 520($t2)
	j ending
	
# draw 7
seven3:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 4($t2)
	sw $t9, 8($t2)
	sw $t9, 136($t2)
	sw $t9, 260($t2)
	sw $t9, 384($t2)
	j ending
	
# draw 8
eight3:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 4($t2)
	sw $t9, 8($t2)
	sw $t9, 128($t2)
	sw $t9, 136($t2)
	sw $t9, 256($t2)
	sw $t9, 260($t2)
	sw $t9, 264($t2)
	sw $t9, 384($t2)
	sw $t9, 392($t2)
	sw $t9, 512($t2)
	sw $t9, 516($t2)
	sw $t9, 520($t2)
	j ending
	
# draw 9
nine3:
	add $t2, $t0, $t3
	sw $t9, ($t2)
	sw $t9, 4($t2)
	sw $t9, 8($t2)
	sw $t9, 128($t2)
	sw $t9, 136($t2)
	sw $t9, 256($t2)
	sw $t9, 260($t2)
	sw $t9, 264($t2)
	sw $t9, 392($t2)
	sw $t9, 512($t2)
	sw $t9, 516($t2)
	sw $t9, 520($t2)
	j ending
	
ending:
	jal keypress_check
	
	li $v0, 32		# sleep for sleep time
	li $a0, SLEEP_TIME
	syscall
	
	j end
