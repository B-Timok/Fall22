###########################################################################
#  Name: Brandon Timok
#  Description: MIPS assembly language program to calculate some geometric 
#  information for each regular hexagon1 in a series of hexagons.


################################################################################
#  data segment

.data

sideLens:
	.word	  15,   25,   33,   44,   58,   69,   72,   86,   99,  101
	.word	 369,  374,  377,  379,  382,  384,  386,  388,  392,  393
	.word	 501,  513,  524,  536,  540,  556,  575,  587,  590,  596
	.word	 634,  652,  674,  686,  697,  704,  716,  720,  736,  753
	.word	 107,  121,  137,  141,  157,  167,  177,  181,  191,  199
	.word	 102,  113,  122,  139,  144,  151,  161,  178,  186,  197
	.word	   1,    2,    3,    4,    5,    6,    7,    8,    9,   10
	.word	 202,  209,  215,  219,  223,  225,  231,  242,  244,  249
	.word	 203,  215,  221,  239,  248,  259,  262,  274,  280,  291
	.word	 251,  253,  266,  269,  271,  272,  280,  288,  291,  299
	.word	1469, 2474, 3477, 4479, 5482, 5484, 6486, 7788, 8492

apothemLens:
	.word	  32,   51,   76,   87,   90,  100,  111,  123,  132,  145
	.word	 634,  652,  674,  686,  697,  704,  716,  720,  736,  753
	.word	 782,  795,  807,  812,  827,  847,  867,  879,  888,  894
	.word	 102,  113,  122,  139,  144,  151,  161,  178,  186,  197
	.word	1782, 2795, 3807, 3812, 4827, 5847, 6867, 7879, 7888, 1894
	.word	 206,  212,  222,  231,  246,  250,  254,  278,  288,  292
	.word	 332,  351,  376,  387,  390,  400,  411,  423,  432,  445
	.word	  10,   12,   14,   15,   16,   22,   25,   26,   28,   29
	.word	 400,  404,  406,  407,  424,  425,  426,  429,  448,  492
	.word	 457,  487,  499,  501,  523,  524,  525,  526,  575,  594
	.word	1912, 2925, 3927, 4932, 5447, 5957, 6967, 7979, 7988

hexAreas:
	.space	436

len:	.word	109

haMin:	.word	0
haEMid:	.word	0
haMax:	.word	0
haSum:	.word	0
haAve:	.word	0

LN_CNTR	= 7

# -----

hdr:	.ascii	"MIPS Assignment #1 \n"
	.ascii	"Program to calculate area of each hexagon in a series "
	.ascii	"of hexagons. \n"
	.ascii	"Also finds min, est mid, max, sum, and average for the "
	.asciiz	"hexagon areas. \n\n"

new_ln:	.asciiz	"\n"
blnks:	.asciiz	"  "

a1_st:	.asciiz	"\nHexagon min = "
a2_st:	.asciiz	"\nHexagon emid = "
a3_st:	.asciiz	"\nHexagon max = "
a4_st:	.asciiz	"\nHexagon sum = "
a5_st:	.asciiz	"\nHexagon ave = "


###########################################################
#  text/code segment

.text
.globl main
.ent main
main:

# -----
#  Display header.

	la	$a0, hdr
	li	$v0, 4
	syscall				# print header

# --------------------------------------------------


# store each array address and variables for calculations

	la	$t0, sideLens
	la 	$t1, apothemLens
	la 	$t5, hexAreas
	lw 	$t6, len

# loop to fill new hexAreas array with all hexagon areas

areaLoop:
	lw		$t2, ($t0)								# loads sidelens element i
	lw		$t3, ($t1)								# loads apothemlens element i
	mulou	$t4, $t2, $t3							# sidelens[i] * apothemlens[i]
	divu 	$t4, $t4, 2								# divide by 2
	mulou 	$t4, $t4, 6								# multiply by 6
	sw	 	$t4, ($t5)								# store answer in hexAreas[i]
	addu 	$t0, $t0, 4								# increment sidelens[i] 
	addu 	$t1, $t1, 4								# increment apothemlens[i]
	addu 	$t5, $t5, 4								# increment hexAreas[i]
	subu	$t6, $t6, 1								# decrement length
	bnez	$t6, areaLoop							# keep looping until length is 0

# store arrays and vars

	la  	$s0, hexAreas							# loads address of hexAreas	

	lw		$t0, ($s0)								# t0 = min
	li		$t1, 0									# t1 = max
	li		$t2, 0									# t2 = running sum
	lw  	$t3, len								# loads length 
	li		$t4, 0									# index = 0

# loop to find the min, max, sum, and ave areas

statloop:
	lw		$t5, ($s0)								# hexAreas[i]
	bge		$t5, $t0, notNewMin						# if greater, check for max
	move	$t0, $t5								# update new min

notNewMin:
	ble		$t5, $t1, notNewMax						# if less than, skip to sum
	move	$t1, $t5								# update new max

notNewMax:
	addu	$t2, $t2, $t5							# sum += hexAreas[i]

# update hexAreas[i]
	addu	$s0, $s0, 4								# increment i
	addu	$t4, $t4, 1								# increment index

	blt		$t4, $t3, statloop

# store stats in their respective variables
	sw 		$t0, haMin
	sw		$t1, haMax
	sw		$t2, haSum

# find average of areas and store in variable
	divu	$t0, $t2, $t3
	sw		$t0, haAve

# calculate estimated median
	la		$s0, hexAreas
	lw		$t0, ($s0)								# first number in array
	div		$t1, $t3, 2
	mulou	$t1, $t1, 4								# (length/2) * word size(4)
	addu	$s0, $s0, $t1							# increment to middle number of array
	lw		$t2, ($s0)								# load 1st middle number into $t2
	addu	$t0, $t0, $t2
	addu	$t0, $t0, $t5							# first + middle + last
	divu	$t0, $t0, 3

	sw		$t0, haEMid

##########################################################
#  Display results.

	la	$a0, new_ln		# print a newline
	li	$v0, 4
	syscall
	la	$a0, new_ln		# print a newline
	li	$v0, 4
	syscall

#  Print new hexAreas array
	la  $s0, hexAreas
	li	$s1, 0
	lw  $s2, len

printLoop:
	li	$v0, 1
	lw  $a0, ($s0)
	syscall
	
	li	$v0, 4
	la  $a0, blnks
	syscall

	addu $s0, $s0, 4
	addu $s1, $s1, 1

	rem  $t0, $s1, 7
	bnez $t0, skipNewLine

	li	$v0, 4
	la  $a0, new_ln
	syscall

skipNewLine:
	bne $s1, $s2, printLoop

	li	$v0, 4
	la  $a0, new_ln
	syscall

#  Print min message followed by result.

	la	$a0, a1_st
	li	$v0, 4
	syscall				# print "min = "

	lw	$a0, haMin
	li	$v0, 1
	syscall				# print min

# -----
#  Print middle message followed by result.

	la	$a0, a2_st
	li	$v0, 4
	syscall				# print "emid = "

	lw	$a0, haEMid
	li	$v0, 1
	syscall				# print emid

# -----
#  Print max message followed by result.

	la	$a0, a3_st
	li	$v0, 4
	syscall				# print "max = "

	lw	$a0, haMax
	li	$v0, 1
	syscall				# print max

# -----
#  Print sum message followed by result.

	la	$a0, a4_st
	li	$v0, 4
	syscall				# print "sum = "

	lw	$a0, haSum
	li	$v0, 1
	syscall				# print sum

# -----
#  Print average message followed by result.

	la	$a0, a5_st
	li	$v0, 4
	syscall				# print "ave = "

	lw	$a0, haAve
	li	$v0, 1
	syscall				# print average

# -----
#  Done, terminate program.

endit:
	la	$a0, new_ln		# print a newline
	li	$v0, 4
	syscall

	li	$v0, 10
	syscall				# all done!

.end main

