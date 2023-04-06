###########################################################################
#  Name: Brandon Timok
#  Description: MIPS assembly language program to calculate the volume of each 
#  three dimensional hexagonal prism1 in a series of hexagonal prisms.


###########################################################
#  data segment

.data

apothems:	.word	  110,   114,   113,   137,   154
		.word	  131,   113,   120,   161,   136
		.word	  114,   153,   144,   119,   142
		.word	  127,   141,   153,   162,   110
		.word	  119,   128,   114,   110,   115
		.word	  115,   111,   122,   133,   170
		.word	  115,   123,   115,   163,   126
		.word	  124,   133,   110,   161,   115
		.word	  114,   134,   113,   171,   181
		.word	  138,   173,   129,   117,   193
		.word	  125,   124,   113,   117,   123
		.word	  134,   134,   156,   164,   142
		.word	  206,   212,   112,   131,   246
		.word	  150,   154,   178,   188,   192
		.word	  182,   195,   117,   112,   127
		.word	  117,   167,   179,   188,   194
		.word	  134,   152,   174,   186,   197
		.word	  104,   116,   112,   136,   153
		.word	  132,   151,   136,   187,   190
		.word	  120,   111,   123,   132,   145

bases:		.word	  233,   214,   273,   231,   215
		.word	  264,   273,   274,   223,   256
		.word	  157,   187,   199,   111,   123
		.word	  124,   125,   126,   175,   194
		.word	  149,   126,   162,   131,   127
		.word	  177,   199,   197,   175,   114
		.word	  244,   252,   231,   242,   256
		.word	  164,   141,   142,   173,   166
		.word	  104,   146,   123,   156,   163
		.word	  121,   118,   177,   143,   178
		.word	  112,   111,   110,   135,   110
		.word	  127,   144,   210,   172,   124
		.word	  125,   116,   162,   128,   192
		.word	  215,   224,   236,   275,   246
		.word	  213,   223,   253,   267,   235
		.word	  204,   229,   264,   267,   234
		.word	  216,   213,   264,   253,   265
		.word	  226,   212,   257,   267,   234
		.word	  217,   214,   217,   225,   253
		.word	  223,   273,   215,   206,   213

heights:	.word	  117,   114,   115,   172,   124
		.word	  125,   116,   162,   138,   192
		.word	  111,   183,   133,   130,   127
		.word	  111,   115,   158,   113,   115
		.word	  117,   126,   116,   117,   227
		.word	  177,   199,   177,   175,   114
		.word	  194,   124,   112,   143,   176
		.word	  134,   126,   132,   156,   163
		.word	  124,   119,   122,   183,   110
		.word	  191,   192,   129,   129,   122
		.word	  135,   226,   162,   137,   127
		.word	  127,   159,   177,   175,   144
		.word	  179,   153,   136,   140,   235
		.word	  112,   154,   128,   113,   132
		.word	  161,   192,   151,   213,   126
		.word	  169,   114,   122,   115,   131
		.word	  194,   124,   114,   143,   176
		.word	  134,   126,   122,   156,   163
		.word	  149,   144,   114,   134,   167
		.word	  143,   129,   161,   165,   136

hexVolumes:	.space	400

len:		.word	100

volMin:		.word	0
volEMid:	.word	0
volMax:		.word	0
volSum:		.word	0
volAve:		.word	0

LN_CNTR	= 4


# -----

hdr:	.ascii	"MIPS Assignment #2 \n"
	.ascii	"  Hexagonal Volumes Program:\n"
	.ascii	"  Also finds minimum, middle value, maximum, \n"
	.asciiz	"  sum, and average for the volumes.\n\n"

a1_st:	.asciiz	"\nHexagon Volumes Minimum = "
a2_st:	.asciiz	"\nHexagon Volumes Est Med  = "
a3_st:	.asciiz	"\nHexagon Volumes Maximum = "
a4_st:	.asciiz	"\nHexagon Volumes Sum     = "
a5_st:	.asciiz	"\nHexagon Volumes Average = "

newLn:	.asciiz	"\n"
blnks:	.asciiz	"  "

###########################################################
#  text/code segment

# --------------------
#  Compute volumes:
#  Then find middle, max, sum, and average for volumes.

.text
.globl main
.ent main
main:

# -----
#  Display header.

	la	$a0, hdr
	li	$v0, 4
	syscall				# print header

# -------------------------------------------------------


#	YOUR CODE GOES HERE

# store each array address and length variable to use for calculations
	la	$t0, apothems
	la	$t1, bases
	la  $t2, heights
	la	$t3, hexVolumes
	lw	$t4, len

# loop to fill new hexVolumes array
volumeLoop:
	lw		$t5, ($t0)							# store first element in $t5
	lw		$t6, ($t1)							# store first element in $t6
	lw		$t7, ($t2)							# store first element in $t7
	mulou	$s0, $t5, $t6						# multiply apothems[i] * bases[i]
	mulou   $s0, $s0, $t7						# multiply result * heights[i]
	mulou	$s0, $s0, 3							# multiply result * 3

# store answer ($s0) in hexVolumes[i] and move to next [i] in each array
	sw 		$s0, ($t3)
	addu	$t0, $t0, 4
	addu	$t1, $t1, 4
	addu	$t2, $t2, 4
	addu	$t3, $t3, 4
	subu	$t4, $t4, 1
	bnez	$t4, volumeLoop

# store arrays and vars

	la  	$s0, hexVolumes							# loads address of hexAreas	

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
	sw 		$t0, volMin
	sw		$t1, volMax
	sw		$t2, volSum

# find average of areas and store in variable
	divu	$t0, $t2, $t3
	sw		$t0, volAve

# calculate estimated median
	la		$s0, hexVolumes
	lw		$t0, ($s0)								# first number in array
	div		$t1, $t3, 2
	mulou	$t1, $t1, 4								# (length/2) * word size(4)
	addu	$s0, $s0, $t1							# increment to middle number of array
	lw		$t2, ($s0)								# load 1st middle number into $t2
	addu	$t0, $t0, $t2
	subu	$s0, $s0, 4
	lw		$t3, ($s0)
	addu	$t0, $t0, $t3
	addu	$t0, $t0, $t5							# first + middle 2 + last
	divu	$t0, $t0, 4

	sw		$t0, volEMid



##########################################################
#  Display results.

	# la	$a0, newLn		# print a newline
	# li	$v0, 4
	# syscall

#  Print new hexAreas array
	la  $s0, hexVolumes
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
	la  $a0, newLn
	syscall

skipNewLine:
	bne $s1, $s2, printLoop

	li	$v0, 4
	la  $a0, newLn
	syscall

#  Print min message followed by result.

	la	$a0, a1_st
	li	$v0, 4
	syscall				# print "min = "

	lw	$a0, volMin
	li	$v0, 1
	syscall				# print min

# -----
#  Print middle message followed by result.

	la	$a0, a2_st
	li	$v0, 4
	syscall				# print "med = "

	lw	$a0, volEMid
	li	$v0, 1
	syscall				# print mid

# -----
#  Print max message followed by result.

	la	$a0, a3_st
	li	$v0, 4
	syscall				# print "max = "

	lw	$a0, volMax
	li	$v0, 1
	syscall				# print max

# -----
#  Print sum message followed by result.

	la	$a0, a4_st
	li	$v0, 4
	syscall				# print "sum = "

	lw	$a0, volSum
	li	$v0, 1
	syscall				# print sum

# -----
#  Print average message followed by result.

	la	$a0, a5_st
	li	$v0, 4
	syscall				# print "ave = "

	lw	$a0, volAve
	li	$v0, 1
	syscall				# print average

# -----
#  Done, terminate program.

endit:
	la	$a0, newLn		# print a newline
	li	$v0, 4
	syscall

	li	$v0, 10
	syscall				# all done!

.end main

