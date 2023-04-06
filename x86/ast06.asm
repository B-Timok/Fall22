; *****************************************************************
;  Name: Brandon Timok
;  Description:	Simple assembly language program to calculate 
;		the diameters of a circle for a series of circles.
;		The circle radii lengths are provided as septenary values
;		represented as ASCII characters and must be converted into
;		integer in order to perform the calculations.

; =====================================================================
;  STEP #2
;  Macro to convert ASCII/septenary value into an integer.
;  Reads <string>, convert to integer and place in <integer>
;  Assumes valid data, no error checking is performed.

;  Arguments:
;	%1 -> <string>, register -> string address
;	%2 -> <integer>, register -> result

;  Macro usgae
;	aSept2int  <string>, <integer>

;  Example usage:
;	aSept2int	rbx, tmpInteger

;  For example, to get address into a local register:
;		mov	rsi, %1

;  Note, the register used for the macro call (rbx in this example)
;  must not be altered before the address is copied into
;  another register (if desired).

%macro	aSept2int	2

;	STEP #2
;	YOUR CODE GOES HERE

	mov r8, %1
	mov rsi, 0

%%skipblanks:
	mov cl, byte [r8 + rsi]
	cmp cl, " "
	jne %%next
	inc rsi
	jmp %%skipblanks

%%next:
	mov ebx, 1
	cmp cl, "-"
	jne %%isPos
	mov ebx, -1

%%isPos:
	inc rsi
	mov eax, 0
	mov ecx, 0

%%nextChar:
	mov cl, byte [r8 + rsi]
	cmp cl, NULL
	je  %%charDone
	sub cl, 0x30
	mov r11d, 7
	mul r11d
	add eax, ecx
	inc rsi
	jmp %%nextChar

%%charDone:
	imul ebx
	mov dword [%2], eax	

%endmacro

; =====================================================================
;  Macro to convert integer to septenary value in ASCII format.
;  Reads <integer>, converts to ASCII/septenary string including
;	NULL into <string>

;  Note, the macro is calling using RSI, so the macro itself should
;	 NOT use the RSI register until is saved elsewhere.

;  Arguments:
;	%1 -> <integer>, value
;	%2 -> <string>, string address

;  Macro usgae
;	int2aSept	<integer-value>, <string-address>

;  Example usage:
;	int2aSept	dword [diamsArrays+rsi*4], tempString

;  For example, to get value into a local register:
;		mov	eax, %1

%macro	int2aSept	2

;	STEP #5
;	YOUR CODE GOES HERE

	mov eax, %1
	mov rcx, 0
	mov r9,  0
	mov r12, 7

%%divLoop:
	cmp eax, 0
	jle %%flipLoop
	mov edx, 0
	cdq
	idiv r12
	push rdx
	inc rcx
	inc r9
	cmp eax, 0
	jne %%divLoop
	jmp %%continue

%%flipLoop:
	neg eax
	jmp %%divLoop

%%continue:
	mov rbx, %2
	mov rdi, 0
	
	mov r8, STR_LENGTH
	dec r8
	sub r8, rcx
	mov rdi, r8
	mov r11, r8
	dec r11
	
%%popLoop:
	pop rax
	add al, "0"
	mov byte [rbx + rdi], al
	inc rdi
	loop %%popLoop

	mov r8, STR_LENGTH
	dec r8
	mov byte [rbx + r8], NULL
	mov r10, 0
	dec rdi
	mov byte [rbx + r11], "+"
	
	cmp %1, 0
	jge %%blankLoop
	mov byte [rbx + r11], "-"
	

	
%%blankLoop:
	mov byte [rbx + r10], " "
	inc r10
	cmp r10, r11
	jne %%blankLoop	
	

%endmacro

; =====================================================================
;  Simple macro to display a string to the console.
;  Count characters (excluding NULL).
;  Display string starting at address <stringAddr>

;  Macro usage:
;	printString  <stringAddr>

;  Arguments:
;	%1 -> <stringAddr>, string address

%macro	printString	1
	push	rax			; save altered registers (cautionary)
	push	rdi
	push	rsi
	push	rdx
	push	rcx

	lea	rdi, [%1]		; get address
	mov	rdx, 0			; character count
%%countLoop:
	cmp	byte [rdi], NULL
	je	%%countLoopDone
	inc	rdi
	inc	rdx
	jmp	%%countLoop
%%countLoopDone:

	mov	rax, SYS_write		; system call for write (SYS_write)
	mov	rdi, STDOUT		; standard output
	lea	rsi, [%1]		; address of the string
	syscall				; call the kernel

	pop	rcx			; restore registers to original values
	pop	rdx
	pop	rsi
	pop	rdi
	pop	rax
%endmacro

; =====================================================================
;  Initialized variables.

section	.data

; -----
;  Define standard constants.

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; successful operation
NOSUCCESS	equ	1			; unsuccessful operation

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; system call code for read
SYS_write	equ	1			; system call code for write
SYS_open	equ	2			; system call code for file open
SYS_close	equ	3			; system call code for file close
SYS_fork	equ	57			; system call code for fork
SYS_exit	equ	60			; system call code for terminate
SYS_creat	equ	85			; system call code for file open/create
SYS_time	equ	201			; system call code for get time

LF		equ	10
SPACE		equ	" "
NULL		equ	0
ESC		equ	27

NUMS_PER_LINE	equ	4


; -----
;  Assignment #6 Provided Data

STR_LENGTH	equ	12			; chars in string, with NULL

septRadii	db	"         +5", NULL, "        +10", NULL, "        +16", NULL
		db	"        +24", NULL, "        +35", NULL, "        +46", NULL
		db	"        +55", NULL, "        +63", NULL, "       +106", NULL
		db	"       +143", NULL, "       +144", NULL, "       +155", NULL
		db	"      -2542", NULL, "      -1610", NULL, "      -1361", NULL
		db	"       +266", NULL, "       +330", NULL, "       +421", NULL
		db	"       +502", NULL, "       +516", NULL, "       +642", NULL
		db	"      +1161", NULL, "      +1135", NULL, "      +1246", NULL
		db	"      -1116", NULL, "      -1000", NULL, "       -136", NULL
		db	"      +1540", NULL, "      +1651", NULL, "      +2151", NULL
		db	"      +2161", NULL, "     +10063", NULL, "     -11341", NULL
		db	"     +12224", NULL
aSeptLength	db	"        +46", NULL
length		dd	0

diamSum		dd	0
diamAve		dd	0
diamMin		dd	0
diamMax		dd	0

; -----
;  Misc. variables for main.

hdr		db	"-----------------------------------------------------"
		db	LF, ESC, "[1m", "CS 218 - Assignment #6", ESC, "[0m", LF
		db	"Diameter Calculations", LF, LF
		db	"Diameters:", LF, NULL
shdr		db	LF, "Diameters Sum:  ", NULL
avhdr		db	LF, "Diameters Ave:  ", NULL
minhdr		db	LF, "Diameters Min:  ", NULL
maxhdr		db	LF, "Diameters Max:  ", NULL

newLine		db	LF, NULL
spaces		db	"   ", NULL

ddTwo		dd	2

; =====================================================================
;  Uninitialized variables

section	.bss

tmpInteger	resd	1				; temporaty value

diamsArray	resd	34

lenString	resb	STR_LENGTH
tempString	resb	STR_LENGTH			; bytes

diamSumString	resb	STR_LENGTH
diamAveString	resb	STR_LENGTH
diamMinString	resb	STR_LENGTH
diamMaxString	resb	STR_LENGTH

; **************************************************************

section	.text
global	_start
_start:

; -----
;  Display assignment initial headers.

	printString	hdr

; -----
;  STEP #1
;	Convert integer length, in ASCII septenary format to integer.
;	Do not use macro here...
;	Read string aSeptLength1, convert to integer, and store in length

;	YOUR CODE GOES HERE

	mov r8, aSeptLength
	mov rsi, 0

skipblanks:
	mov cl, byte [r8 + rsi]
	cmp cl, " "
	jne next
	inc rsi
	jmp skipblanks

next:
	mov ebx, 1
	cmp cl, "-"
	jne isPos
	mov ebx, -1

isPos:
	inc rsi
	mov eax, 0
	mov ecx, 0

nextChar:
	mov cl, byte [r8 + rsi]
	cmp cl, NULL
	je  charDone
	sub cl, 0x30
	mov r11d, 7
	mul r11d
	add eax, ecx
	inc rsi
	jmp nextChar

charDone:
	imul ebx
	mov dword [length], eax	

; -----
;  Convert radii from ASCII/septenary format to integer.
;  STEP #2 must complete before this code.

	mov	ecx, dword [length]
	mov	rdi, 0					; index for radii
	mov	rbx, septRadii
cvtLoop:
	push	rbx					; safety push
	push	rcx
	push	rdi
	aSept2int	rbx, tmpInteger
	pop	rdi
	pop	rcx
	pop	rbx

	mov	eax, dword [tmpInteger]
	mul	dword [ddTwo]				; diam = radius * 2
	mov	dword [diamsArray+rdi*4], eax
	add	rbx, STR_LENGTH

	inc	rdi
	dec	ecx
	cmp	ecx, 0
	jne	cvtLoop

; -----
;  Display each the diamsArray (four per line).

	mov	ecx, dword [length]
	mov	rsi, 0
	mov	r12, 0
printLoop:
	push	rcx					; safety push
	push	rsi
	push	r12

	mov	ebp, dword [diamsArray+rsi*4]
	int2aSept	ebp, tempString

	printString	tempString
	printString	spaces

	pop	r12
	pop	rsi
	pop	rcx

	inc	r12
	cmp	r12, 4
	jne	skipNewline
	mov	r12, 0
	printString	newLine
skipNewline:
	inc	rsi

	dec	ecx
	cmp	ecx, 0
	jne	printLoop
	printString	newLine

; -----
;  STEP #3
;	Find diamaters array stats (sum, min, max, and average).
;	Reads data from diamsArray (set above).

;	YOUR CODE GOES HERE

; Compute the sum of the elements of diamsArray

	mov eax, dword [diamsArray]
	mov dword [diamSum], eax
	mov rsi, 1
	mov ecx, dword [length]
	dec ecx

sumloop:
	mov eax, dword [diamsArray + rsi * 4]
	add dword [diamSum], eax
	inc rsi
	loop sumloop

; *****

; Compute the average of the elements of diamsArray

; divide the sum by the length

	mov eax, dword [diamSum]
	cdq
	mov esi, dword [length]
	idiv esi
	mov dword [diamAve], eax

; *****

; Compute the min of the elements of diamsArray

; if (diamsArray[n] < diamMin)
;	diamMin = diamsArray[n]

	mov eax, dword [diamsArray]
	mov dword [diamMax], eax
	mov rsi, 0
	mov ecx, dword [length]

minloop:
	mov eax, dword [diamsArray + rsi * 4]
	cmp dword [diamMax], eax
	jge minDone
	mov dword [diamMax], eax

minDone:
	inc rsi
	loop minloop
	
; *****

; Compute the max of the elements of diamsArray

; if (diamsArray[n] > diamMax)
;	diamMax = diamsArray[n]

	mov eax, dword [diamsArray]
	mov dword [diamMin], eax
	mov rsi, 0
	mov ecx, dword [length]

maxloop:
	mov eax, dword [diamsArray + rsi * 4]
	cmp dword [diamMin], eax
	jle maxDone
	mov dword [diamMin], eax

maxDone:
	inc rsi 
	loop maxloop

; *****

; -----
;  STEP #4
;	Convert sum to ASCII/septenary for printing.
;	Do not use macro here...

	printString	shdr

;	Read diamsArray sum integer (set above), convert to
;		ASCII/septenary and store in diamSumString.

;	YOUR CODE GOES HERE

	mov eax, dword [diamSum]
	mov rcx, 0
	mov r9,  0
	mov r12, 7

divLoop:
	cmp eax, 0
	jle flipLoop
	mov edx, 0
	cdq
	idiv r12
	push rdx
	inc rcx
	inc r9
	cmp eax, 0
	jne divLoop
	jmp continue

flipLoop:
	neg eax
	jmp divLoop

continue:
	mov rbx, diamSumString
	mov rdi, 0
	
	mov r8, STR_LENGTH
	dec r8
	sub r8, rcx
	mov rdi, r8
	mov r11, r8
	dec r11
	
popLoop:
	pop rax
	add al, "0"
	mov byte [rbx + rdi], al
	inc rdi
	loop popLoop

	mov r8, STR_LENGTH
	dec r8
	mov byte [rbx + r8], NULL
	mov r10, 0
	dec rdi
	mov byte [rbx + r11], "+"
	
	cmp dword [diamSum], 0
	jge blankLoop
	mov byte [rbx + r11], "-"
	

	
blankLoop:
	mov byte [rbx + r10], " "
	inc r10
	cmp r10, r11
	jne blankLoop
	

;	print the diamSumString (set above).
	printString	diamSumString

; -----
;  Convert average, min, and max integers to ASCII/septenary for printing.
;  STEP #5 must complete before this code.

	printString	avhdr
	int2aSept	dword [diamAve], diamAveString
	printString	diamAveString

	printString	minhdr
	int2aSept	dword [diamMin], diamMinString
	printString	diamMinString

	printString	maxhdr
	int2aSept	dword [diamMax], diamMaxString
	printString	diamMaxString

	printString	newLine
	printString	newLine

; *****************************************************************
;  Done, terminate program.

last:
	mov	rax, SYS_exit
	mov	rdi, EXIT_SUCCESS
	syscall

