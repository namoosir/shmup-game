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
.eqv	SLEEP_TIME	80
.eqv	SHIP_LEN	80
.eqv	OBS1_LEN	40

.data
# miscellaneous
lives:		.word	3

# ship
ship:		.word	0, 0xffffff, 124, 0xffffff, 4, 0x5c8ab5, 4, 0x5c8ab5, 4, 0xffffff, 116, 0xffffff, 4, 0x5c8ab5, 4, 0x5c8ab5, 4, 0xffffff, 120, 0xffffff
currShipLoc:	.word	1812
newShipLoc:	.word	1812

# obstacle 1
obs1:		.word	0, 0x9a9fb3, 124, 0x9a9fb3, 4, 0x797b85, 4, 0x9a9fb3, 124, 0x9a9fb3
currObs1Loc:	.word	0
newObs1Loc:	.word	0



.text

.globl main

main:
	li $t0, BASE_ADDRESS	# get base address of display
	li $t1, 0		# index
	li $t2, 4		# increment
	li $t3, 16384		# total length
	
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
	
	jal eraseall		# erase everything on the screen
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
	
	beq $t3, $0, getNew	# obstacle out of screen, generate new one
	
	subi $t1, $t1, 4	# update the current location
	
	la $t2, newObs1Loc	# get new location of obstacle 1
	sw $t1, ($t2)		# set new location to the updated current location
	
# generate new obstacles	
getNew:
	li $v0, 42		# randomly generate location of obstacle 1
	li $a0, 0
	li $a1, 31
	move $t5, $a1
	li $t9, 4
	mult $t5, $t9
	mflo $t5
	li $t9, 128
	mult $t5, $t9
	mflo $t5
	subi $t5, $t5, 4
	
	move $t2, $t5		# set the new location	
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
	jr $ra			# return

# updates location of ship if a is pressed	
respond_to_d:
	jr $ra 			# return

# updates location of ship if a is pressed	
respond_to_s:
	jr $ra 			# return

# updates location of ship if a is pressed
respond_to_w:
	jr $ra 			# return

respond_to_p:
	j main

# checks for collisions, returns 1 if collided, 0 otherwise in $v0
collision_check:
	jr $ra			# return


# erase everything on the screen
eraseall:
	li $t0, BASE_ADDRESS	# get base address of display
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
	
eraseObs1:
	add $t6, $t5, $t2	# calculate offset
	lw $t7, ($t6)		# get pixel location
	
	add $t3, $t3, $t7	# get offset for pixel array
	sw $0, ($t3)		# store 0 to erase
	
	addi $t5, $t5, 8		# update index
	bne $t4, $t5, eraseObs1		# looping condition
	
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
	add $t8, $t4, $t7	# offset for obstacle 1 array
	lw $t9, ($t8)		# location of pixel
	lw $t1, 4($t8)		# color of pixel
	
	add $t4, $t4, $t9	# calculate offset for pixel array
	sw $t1, ($t4)		# set color of pixel
	
	addi $t7, $t7, 8	# update index
	bne $t7, $t6, obs1Loop	# looping condition
	
	
	
	jr $ra			# return

	

# end the program
end:
	li $v0, 10
	syscall
