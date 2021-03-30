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

.data
lives:	.word	3
ship:	.word	0xff0000


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
	li $t2, 4		# increment
	li $t3, 16384		# total length

# loop through all elements
erase:
	add $t4, $t0, $t1	# calculate offset
	sw $0, ($t4)		# store 0 into array
	
	add $t1, $t1, $t2	# update index
	bne $t3, $t1, erase	# looping condition
	
	jr $ra			# return
	
# draw function
draw:
	li $t0, BASE_ADDRESS	# get the base address
	li $t1, 0xffffff	# get the color white
	li $t2, 0x5c8ab5	# get another color
	
	sw $t1, 1812($t0)	
	sw $t1, 1936($t0)
	sw $t2, 1940($t0)
	sw $t2, 1944($t0)
	sw $t1, 1948($t0)
	sw $t1, 2064($t0)
	sw $t2, 2068($t0)
	sw $t2, 2072($t0)
	sw $t1, 2076($t0)
	sw $t1, 2196($t0)
	
	
	jr $ra			# return

# end the program
end:
	li $v0, 10
	syscall