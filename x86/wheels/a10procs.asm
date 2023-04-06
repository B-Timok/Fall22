; *****************************************************************
;  Name: Brandon Timok
;  Description: Assembly program that constructs a spinning wheel with the use of OpenGL


; -----
;  Function: getParams
;	Gets, checks, converts, and returns command line arguments.

;  Function drawWheels()
;	Plots functions

; ---------------------------------------------------------

;	MACROS (if any) GO HERE


; ---------------------------------------------------------

section  .data

; -----
;  Define standard constants.

TRUE		equ	1
FALSE		equ	0

SUCCESS		equ	0			; successful operation
NOSUCCESS	equ	1

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; code for read
SYS_write	equ	1			; code for write
SYS_open	equ	2			; code for file open
SYS_close	equ	3			; code for file close
SYS_fork	equ	57			; code for fork
SYS_exit	equ	60			; code for terminate
SYS_creat	equ	85			; code for file open/create
SYS_time	equ	201			; code for get time

LF			equ	10
SPACE		equ	" "
NULL		equ	0
ESC			equ	27

; -----
;  OpenGL constants

GL_COLOR_BUFFER_BIT	equ	16384
GL_POINTS			equ	0
GL_POLYGON			equ	9
GL_PROJECTION		equ	5889

GLUT_RGB			equ	0
GLUT_SINGLE			equ	0

; -----
;  Define program specific constants.

SPD_MIN		equ	1
SPD_MAX		equ	50				; 101(7) = 50

CLR_MIN		equ	0
CLR_MAX		equ	0xFFFFFF		; 0xFFFFFF = 262414110(7)

SIZ_MIN		equ	100				; 202(7) = 100
SIZ_MAX		equ	2000			; 5555(7) = 2000

; -----
;  Local variables for getParams functions.

STR_LENGTH	equ	12

errUsage	db	"Usage: ./wheels -sp <septNumber> -cl <septNumber> "
			db	"-sz <septNumber>"
			db	LF, NULL
errBadCL	db	"Error, invalid or incomplete command line argument."
			db	LF, NULL

errSpdSpec	db	"Error, speed specifier incorrect."
			db	LF, NULL
errSpdValue	db	"Error, speed value must be between 1 and 101(7)."
			db	LF, NULL

errClrSpec	db	"Error, color specifier incorrect."
			db	LF, NULL
errClrValue	db	"Error, color value must be between 0 and 262414110(7)."
			db	LF, NULL

errSizSpec	db	"Error, size specifier incorrect."
			db	LF, NULL
errSizValue	db	"Error, size value must be between 202(7) and 5555(7)."
			db	LF, NULL

; -----
;  Local variables for drawWheels routine.

t			dq	0.0				; loop variable
s			dq	0.0
tStep		dq	0.001			; t step
sStep		dq	0.0
x			dq	0				; current x
y			dq	0				; current y
scale		dq	7500.0			; speed scale

fltZero		dq	0.0
fltOne		dq	1.0
fltTwo		dq	2.0
fltThree	dq	3.0
fltFour		dq	4.0
fltSix		dq	6.0
fltTwoPiS	dq	0.0
fl2C2psD3   dq  0.0
fl2S2psD3   dq  0.0
flt2piD3    dq  0.0
flt6pi      dq  0.0

pi			dq	3.14159265358

fltTmp1		dq	0.0
fltTmp2		dq	0.0

red			dd	0				; 0-255
green		dd	0				; 0-255
blue		dd	0				; 0-255


; ------------------------------------------------------------

section  .text

; -----
; Open GL routines.

extern	glutInit, glutInitDisplayMode, glutInitWindowSize, glutInitWindowPosition
extern	glutCreateWindow, glutMainLoop
extern	glutDisplayFunc, glutIdleFunc, glutReshapeFunc, glutKeyboardFunc
extern	glutSwapBuffers, gluPerspective, glutPostRedisplay
extern	glClearColor, glClearDepth, glDepthFunc, glEnable, glShadeModel
extern	glClear, glLoadIdentity, glMatrixMode, glViewport
extern	glTranslatef, glRotatef, glBegin, glEnd, glVertex3f, glColor3f
extern	glVertex2f, glVertex2i, glColor3ub, glOrtho, glFlush, glVertex2d

extern	cos, sin

; ******************************************************************
; Function aSept2int

; Converts an ASCII/Septenary number to an integer

global aSept2int
aSept2int:

; prologue
	push rbp
	mov rbp, rsp
	push rbx
	push r11
	push r12
	push r13

	mov r13, 0
	mov r12, 0

skipblanks:
	mov cl, byte [rdi + r12]
	cmp cl, " "
	jne nextChar
	inc r12
	jmp skipblanks

nextChar:
	mov rcx, 0
	mov cl, byte [rdi + r12]
	cmp cl, NULL
	je  validity
	sub cl, 0x30
	mov r11d, 7
	cmp cl, r11b
	jge badEnd
	mov r9, 0
	cmp cl, r9b
	jl  badEnd
	mul r11d
	add eax, ecx
	inc r12
	jmp nextChar

badEnd:
	mov rax, errBadCL
	jmp validity

validity:

; epilogue
	pop r13
	pop r12
	pop r11
	pop rbx
	mov rsp, rbp
	pop rbp

	ret

; ******************************************************************
;  Function getParams()
;	Gets draw speed, draw color, and screen size
;	from the command line arguments.

;	Performs error checking, converts ASCII/septenary to integer.
;	Command line format (fixed order):
;	  "-sp <septNumber> -cl <septNumber> -sz <septNumber>"

; -----
;  Arguments:
;	ARGC, double-word, value
;	ARGV, double-word, address
;	speed, double-word, address
;	color, double-word, address
;	size, double-word, address

; Returns:
;	speed, color, and size via reference (of all valid)
;	TRUE or FALSE



;	YOUR CODE GOES HERE

global getParams
getParams:
	push rbp
	mov	 rbp, rsp
	push rbx
	push r12
	push r13

	mov r12, rdi
	mov r13, rsi

	cmp r12, 1
	je  errUse

	cmp r12, 7
	jne errBdcl

	mov rbx, qword [rsi + 8]
	mov al, byte [rbx]
	cmp al, "-"
	jne errSPspec

	mov al, byte [rbx + 1]
	cmp al, "s"
	jne errSPspec

	mov al, byte [rbx + 2]
	cmp al, "p"
	jne errSPspec

	mov al, byte [rbx + 3]
	cmp al, NULL
	jne errSPspec

	mov rdi, qword [rsi + 16]
	call aSept2int
	cmp eax, 0
	jl  errSpdval
	cmp eax, errBadCL
	je  errSpdval
	cmp eax, SPD_MIN
	jb  errSpdval
	cmp eax, SPD_MAX
	ja  errSpdval

	
	mov dword [speed], eax
	mov rax, 0

	mov rbx, qword [rsi + 24]
	mov al, byte [rbx]
	cmp al, "-"
	jne errClspec

	mov al, byte [rbx + 1]
	cmp al, "c"
	jne errClspec

	mov al, byte [rbx + 2]
	cmp al, "l"
	jne errClspec

	mov al, byte [rbx + 3]
	cmp al, NULL
	jne errClspec

	mov rdi, qword [rsi + 32]
	call aSept2int
	cmp eax, 0
	jl  errClval
	cmp eax, errBadCL
	je  errClval
	cmp eax, CLR_MIN
	jb  errClval
	cmp eax, CLR_MAX
	ja  errClval

	mov dword [color], eax
	mov edx, eax
	and edx, 0xFF0000
	shr edx, 16
	mov dword [red], edx
	mov edx, eax
	and edx, 0x00FF00
	shr edx, 8
	mov dword [green], edx
	mov edx, eax
	and edx, 0x0000FF
	mov dword [blue], edx
	mov edx, 0
	mov eax, 0

	mov rbx, qword [rsi + 40]
	mov al, byte [rbx]
	cmp al, "-"
	jne errSzspec

	mov al, byte [rbx + 1]
	cmp al, "s"
	jne errSzspec

	mov al, byte [rbx + 2]
	cmp al, "z"
	jne errSzspec

	mov al, byte [rbx + 3]
	cmp al, NULL
	jne errSzspec

	mov rdi, qword [rsi + 48]
	call aSept2int
	cmp eax, 0
	jl  errSzval
	cmp eax, errBadCL
	je  errSzval
	cmp eax, SIZ_MIN
	jb  errSzval
	cmp eax, SIZ_MAX
	ja  errSzval

	mov dword [size], eax
	mov rax, 0
	jmp getParamsTrue

errUse:
	mov rdi, errUsage
	jmp printmsg

errBdcl:
	mov rdi, errBadCL
	jmp printmsg

errSPspec:
	mov rdi, errSpdSpec
	jmp printmsg

errSpdval:
	mov rdi, errSpdValue
	jmp printmsg

errClspec:
	mov rdi, errClrSpec
	jmp printmsg

errClval:
	mov rdi, errClrValue
	jmp printmsg

errSzspec:
	mov rdi, errSizSpec
	jmp printmsg

errSzval:
	mov rdi, errSizValue
	jmp printmsg

printmsg:
	call printString
	mov rax, FALSE
	jmp getParamsFalse

getParamsTrue:
	mov rax, TRUE

getParamsFalse:

	pop r13
	pop r12
	pop rbx
	mov rsp, rbp
	pop rbp

	ret


; ******************************************************************
;  Draw wheels function.
;	Plot the provided functions (see PDF).

; -----
;  Arguments:
;	none -> accesses global variables.
;	nothing -> is void

; -----
;  Gloabl variables Accessed:

common	speed		1:4			; draw speed, dword, integer value
common	color		1:4			; draw color, dword, integer value
common	size		1:4			; screen size, dword, integer value

global drawWheels
drawWheels:
	push	rbp

; do NOT push any additional registers.
; If needed, save register to quad variable...

; -----
;  Set draw speed step
;	sStep = speed / scale

;	YOUR CODE GOES HERE

	cvtsi2sd xmm0, dword [speed]
	divsd xmm0, qword [scale]
	movsd qword [sStep], xmm0

; -----
;  Prepare for drawing
	; glClear(GL_COLOR_BUFFER_BIT);
	mov	rdi, GL_COLOR_BUFFER_BIT
	call	glClear

	; glBegin();
	mov	rdi, GL_POINTS
	call	glBegin

; -----
;  Set draw color(r,g,b)
;	uses glColor3ub(r,g,b)

;	YOUR CODE GOES HERE

	mov edi, dword [red]
	mov esi, dword [green]
	mov edx, dword [blue]
	call glColor3ub
; -----
;  main plot loop
;	iterate t from 0.0 to 2*pi by tStep
;	uses glVertex2d(x,y) for each formula

; set variables for calculations

	movsd xmm0, qword [fltTwo]
	mulsd xmm0, qword [pi]
	movsd qword [fltTmp1], xmm0				; xmm0 = 2pi

	mulsd xmm0, qword [s]
	movsd qword [fltTwoPiS], xmm0

	movsd xmm0, qword [pi]
	mulsd xmm0, qword [fltTwo]
	divsd xmm0, qword [fltThree]
	movsd qword [flt2piD3], xmm0

	movsd xmm0, qword [fltTwoPiS]
	call cos								; xmm0 = cos(2pis)
	mulsd xmm0, qword [fltTwo]				; xmm0 = 2cos(2pis)
	divsd xmm0, qword [fltThree]			; xmm0 = 2cos(2pis)/3
	movsd qword [fl2C2psD3], xmm0

	movsd xmm0, qword [fltTwoPiS]
	call sin								; xmm0 = sin(2pis)
	mulsd xmm0, qword [fltTwo]				; xmm0 = 2sin(2pis)
	divsd xmm0, qword [fltThree]			; xmm0 = 2sin(2pis)/3
	movsd qword [fl2S2psD3], xmm0

	movsd xmm0, qword [pi]
	mulsd xmm0, qword [fltSix]
	movsd qword [flt6pi], xmm0


;	YOUR CODE GOES HERE
	movsd xmm0, qword [fltZero]
	movsd qword [t], xmm0

mainplotloop:
; plot x1 and y1
	movsd xmm0, qword [t]
	call cos
	movsd qword [x], xmm0
	movsd xmm0, qword [t]
	call sin
	movsd qword [y], xmm0

	movsd xmm0, qword [x]
	movsd xmm1, qword [y]
	call glVertex2d

; plot x2 and y2
	movsd xmm0, qword [t]
	call cos								; xmm0 = cos(t)
	divsd xmm0, qword [fltThree]
	movsd qword [fltTmp2], xmm0				; fltTmp2 = cos(t)/3
	movsd xmm0, qword [fl2C2psD3]
	addsd xmm0, qword [fltTmp2]
	movsd qword [x], xmm0

	movsd xmm0, qword [t]
	call sin								; xmm0 = sin(t)
	divsd xmm0, qword [fltThree]
	movsd qword [fltTmp2], xmm0				; fltTmp2 = sin(t)/3
	movsd xmm0, qword [fl2S2psD3]
	addsd xmm0, qword [fltTmp2]
	movsd qword [y], xmm0

	movsd xmm0, qword [x]
	movsd xmm1, qword [y]
	call glVertex2d

; plot x3 and y3
	movsd xmm0, qword [fl2C2psD3]
	movsd qword [fltTmp2], xmm0
	movsd xmm0, qword [fltTwoPiS]
	mulsd xmm0, qword [fltTwo]
	call cos
	mulsd xmm0, qword [t]
	divsd xmm0, qword [flt6pi]
	addsd xmm0, qword [fltTmp2]
	movsd qword [x], xmm0

	movsd xmm0, qword [fl2S2psD3]
	movsd qword [fltTmp2], xmm0
	movsd xmm0, qword [fltTwoPiS]
	mulsd xmm0, qword [fltTwo]
	call sin
	mulsd xmm0, qword [t]
	divsd xmm0, qword [flt6pi]
	movsd xmm1, qword [fltTmp2]
	subsd xmm1, xmm0
	movsd qword [y], xmm1

	movsd xmm0, qword [x]
	movsd xmm1, qword [y]
	call glVertex2d

; plot x4 and y4
	movsd xmm0, qword [fl2C2psD3]
	movsd qword [fltTmp2], xmm0						; fltTmp2 = first half
	movsd xmm0, qword [fltTwoPiS]
	mulsd xmm0, qword [fltTwo]
	addsd xmm0, qword [flt2piD3]
	call cos 
	mulsd xmm0, qword [t]
	divsd xmm0, qword [flt6pi]
	addsd xmm0, qword [fltTmp2]
	movsd qword [x], xmm0

	movsd xmm0, qword [fl2S2psD3]
	movsd qword [fltTmp2], xmm0						; fltTmp2 = first half
	movsd xmm0, qword [fltTwoPiS]
	mulsd xmm0, qword [fltTwo]
	addsd xmm0, qword [flt2piD3]
	call sin 
	mulsd xmm0, qword [t]
	divsd xmm0, qword [flt6pi]
	movsd xmm1, qword [fltTmp2]
	subsd xmm1, xmm0
	movsd qword [y], xmm1

	movsd xmm0, qword [x]
	movsd xmm1, qword [y]
	call glVertex2d

; plot x5 and y5
	movsd xmm0, qword [fl2C2psD3]
	movsd qword [fltTmp2], xmm0
	movsd xmm0, qword [fltTwoPiS]
	mulsd xmm0, qword [fltTwo]
	subsd xmm0, qword [flt2piD3]
	call cos
	mulsd xmm0, qword [t]
	divsd xmm0, qword [flt6pi]
	addsd xmm0, qword [fltTmp2]
	movsd qword [x], xmm0

	movsd xmm0, qword [fl2S2psD3]
	movsd qword [fltTmp2], xmm0
	movsd xmm0, qword [fltTwoPiS]
	mulsd xmm0, qword [fltTwo]
	subsd xmm0, qword [flt2piD3]
	call sin
	mulsd xmm0, qword [t]
	divsd xmm0, qword [flt6pi]
	movsd xmm1, qword [fltTmp2]
	subsd xmm1, xmm0
	movsd qword [y], xmm1

	movsd xmm0, qword [x]
	movsd xmm1, qword [y]
	call glVertex2d

; increment t
	movsd xmm0, qword [t]
	addsd xmm0, qword [tStep]
	movsd qword [t], xmm0
	ucomisd xmm0, qword [fltTmp1]
	jb mainplotloop

; -----
;  Display image

	call	glEnd
	call	glFlush

; -----
;  Update s, s += sStep;
;  if (s > 1.0)
;	s = 0.0;

	movsd	xmm0, qword [s]			; s+= sStep
	addsd	xmm0, qword [sStep]
	movsd	qword [s], xmm0

	movsd	xmm0, qword [s]
	movsd	xmm1, qword [fltOne]
	ucomisd	xmm0, xmm1			; if (s > 1.0)
	jbe	resetDone

	movsd	xmm0, qword [fltZero]
	movsd	qword [sStep], xmm0
resetDone:

	call	glutPostRedisplay

; -----

	pop	rbp
	ret

; ******************************************************************
;  Generic function to display a string to the screen.
;  String must be NULL terminated.
;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters

;  Arguments:
;	1) address, string
;  Returns:
;	nothing

global	printString
printString:
	push	rbx

; -----
;  Count characters in string.

	mov	rbx, rdi			; str addr
	mov	rdx, 0
strCountLoop:
	cmp	byte [rbx], NULL
	je	strCountDone
	inc	rbx
	inc	rdx
	jmp	strCountLoop
strCountDone:

	cmp	rdx, 0
	je	prtDone

; -----
;  Call OS to output string.

	mov	rax, SYS_write			; system code for write()
	mov	rsi, rdi			; address of characters to write
	mov	rdi, STDOUT			; file descriptor for standard in
						; EDX=count to write, set above
	syscall					; system call

; -----
;  String printed, return to calling routine.

prtDone:
	pop	rbx
	ret

; ******************************************************************

