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
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4 (choose the one the applies)
#
# Which approved features have been implemented for milestone 4?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes / no/ yes, and please share this project githublink as well!
#
# Any additional information that the TA needs to know:
# - (write here, if any)
######################################################################

.eqv	BASE_ADDRESS	0x10008000
.eqv	SLEEP_TIME	40
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
	
	move $a1, $v0		# update parameters of eraseall
	move $a2, $s0
	jal eraseall		# erase everything on the screen
	
	move $a1, $s0		# update parameter of draw
	jal draw		# draw everything
	
	
	beq $0, $s0, end	# lives are at 0, game over
	
	li $v0, 32		# sleep for SLEEP_TIME
	li $a0, SLEEP_TIME
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

	

# end the program
end:
	li $v0, 10
	syscall
