; *****************************************************************
;  Name: Brandon Timok
;  Description: Assembly language program that includes different functions that can be called from a c++ main.

; -----------------------------------------------------------------------------
;  Write assembly language functions.

;  Function, shellSort(), sorts the numbers into ascending
;  order (small to large).  Uses the shell sort algorithm
;  modified to sort in ascending order.

;  Function lstSum() to return the sum of a list.

;  Function lstAverage() to return the average of a list.
;  Must call the lstSum() function.

;  Fucntion basicStats() finds the minimum, median, and maximum,
;  sum, and average for a list of numbers.
;  The median is determined after the list is sorted.
;  Must call the lstSum() and lstAverage() functions.

;  Function linearRegression() computes the linear regression.
;  for the two data sets.  Must call the lstAverage() function.

;  Function readSeptNum() should read a septenary number
;  from the user (STDIN) and perform apprpriate error checking.

; ******************************************************************************

section	.data

; -----
;  Define standard constants.

TRUE			equ	1
FALSE			equ	0

EXIT_SUCCESS	equ	0				; Successful operation

STDIN			equ	0				; standard input
STDOUT			equ	1				; standard output
STDERR			equ	2				; standard error

SYS_read		equ	0				; system call code for read
SYS_write		equ	1				; system call code for write
SYS_open		equ	2				; system call code for file open
SYS_close		equ	3				; system call code for file close
SYS_fork		equ	57				; system call code for fork
SYS_exit		equ	60				; system call code for terminate
SYS_creat		equ	85				; system call code for file open/create
SYS_time		equ	201				; system call code for get time

LF				equ	10
SPACE			equ	" "
NULL			equ	0
ESC				equ	27

; -----
;  Define program specific constants.

SUCCESS 		equ	0
NOSUCCESS		equ	1
OUTOFRANGEMIN	equ	2
OUTOFRANGEMAX	equ	3
INPUTOVERFLOW	equ	4
ENDOFINPUT		equ	5

LIMIT			equ	1510

MIN				equ	-100000
MAX				equ	100000

BUFFSIZE		equ	50				; 50 chars including NULL

; -----
;  NO static local variables allowed...


; ******************************************************************************

section	.text

; -----------------------------------------------------------------------------

global aSept2int
aSept2int:

; prologue
	push rbp
	mov rbp, rsp
	push rbx
	push r11
	push r12
	push r13
	push r14

	mov r14, 0
	mov r12, 0

skipblanks:
	mov cl, byte [rdi + r12]
	cmp cl, " "
	jne next
	inc r12
	jmp skipblanks

next:
	mov ebx, 1
	cmp cl, "-"
	jne checkPos
	mov ebx, -1
	jmp isPos

checkPos:
	cmp cl, "+"
	jne badEnd

isPos:
	inc r12
	mov eax, 0
	mov ecx, 0

nextChar:
	mov cl, byte [rdi + r12]
	cmp cl, NULL
	je  charDone
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

charDone:
	imul ebx
	shl  rdx, 32
	add  rdx, rax
	add  r14, rdx
	jmp  endConv

badEnd:
	mov rax, NOSUCCESS
	jmp validity

endConv:
	mov r8, r14
	cmp r8, MIN
	jl  minRange
	cmp r8, MAX
	jg  maxRange
	mov rax, SUCCESS
	jmp validity


minRange:
	mov rax, OUTOFRANGEMIN
	jmp validity

maxRange:
	mov rax, OUTOFRANGEMAX

validity:

; epilogue
	pop r14
	pop r13
	pop r12
	pop r11
	pop rbx
	mov rsp, rbp
	pop rbp

	ret

; -----------------------------------------------------------------------------
;  Read an ASCII septenary number from the user.

;  Return codes:
;	SUCCESS				Successful conversion
;	NOSUCCESS			Invalid input entered
;	OUTOFRANGEMIN		Input below minimum value
;	OUTOFRANGEMAX		Input above maximum value
;	INPUTOVERFLOW		User entry character count exceeds maximum length
;	ENDOFINPUT			End of the input

; -----
;  Call:
;	status = readSeptNum(&numberRead);

;  Arguments Passed:
;	1) numberRead, addr - rdi

;  Returns:
;	number read (via reference)
;	status code (as above)

global readSeptNum
readSeptNum:

; prologue

	push rbp
	mov rbp, rsp
	sub rsp, 55
	push rbx
	push r11
	push r12
	push r13
	push r14

	mov r12d, dword [rbp - 54]
	mov r14, rdi							; save rdi into other register
	mov r8, 0

; loop to read user input

	lea rbx, byte [rbp - 50]				; load address of buffer into rbx
	mov byte [rbx], LF
	mov r13, 0								; count variable i = 0

; read string one byte at a time

getChar:
	mov rax, SYS_read						; system code for read
	mov rdi, STDIN							
	lea rsi, byte [rbp - 55]				; loads address of char
	mov rdx, 1								; how many to read
	syscall

; if char = LF then exit loop

	mov al, byte [rbp - 55]					; get character to read
	cmp al, LF								; if linefeed then done
	je  inputDone
	
; if i < (buffsize - 1) 
	inc r8
	cmp r13, BUFFSIZE - 1
	jae getChar
	mov byte [rbx + r13], al				; insert char into tmpArr
	inc r13

	jmp getChar

inputDone:
; if input > BUFFSIZE then set status code and exit function
	cmp r8, BUFFSIZE
	jbe checkInput
	mov rax, INPUTOVERFLOW
	jmp readFuncDone

checkInput:
; manually add null to end of temp array
	cmp byte [rbx], LF
	je  endinput
	mov byte [rbx + r13], NULL

convertLoop:
	mov rdi, rbx
	call aSept2int
	cmp rax, SUCCESS
	jg  readFuncDone
	mov rdi, r14
	mov dword [rdi], r8d
	mov rax, SUCCESS
	jmp readFuncDone

endinput:
	mov rax, ENDOFINPUT

readFuncDone:
	pop r14
	pop r13
	pop r12
	pop r11
	pop rbx
	mov rsp, rbp
	pop rbp

	ret

; -----------------------------------------------------------------------------
;  Shell sort function.

; -----
;  HLL Call:
;	call shellSort(list, len)

;  Arguments Passed:
;	1) list, addr
;	2) length, value

;  Returns:
;	sorted list (list passed by reference)


;	YOUR CODE GOES HERE

global	shellSort
shellSort:

; prologue

; h		dd	0
; i		dd	0
; tmp	dd	0

    push rbp
    mov rbp, rsp
    sub rsp, 8
    push rbx
    push r10
    mov r10, 0
    push r11
    push r12
    push r13
    push r14
    mov dword [rbp - 8], 0                      ; h
    mov dword [rbp - 4], 0                      ; tmp
; h = 1

	mov eax, dword [rbp - 8]					; eax = h = 0
	inc eax										; eax = 1
	mov dword [rbp - 8], eax					; h = 1

; while ( (h*3+1) < a.length )

; condition for while 

while:
	mov eax, dword [rbp - 8]
	mov rbx, 3									; rsi = 3
	mul rbx										; eax * rsi = (3 * 1) = 3
	inc eax										; 3 + 1 = 4
	cmp eax, esi						        ; compares eax to length (4 < 200)
	jge endwhile								; if condition is met then done with while

; while body { h = 3 * h + 1; }

whilebody:
	mov eax, dword [rbp - 8]					; eax = h
	mul rbx										; eax * rsi = (h * 3) = eax
	inc eax										; eax + 1 = (h * 3 + 1)
	mov dword [rbp - 8], eax					; h = h * 3 + 1
	jmp while									; back to condition for while with updated (h)

; for when the condition is met

endwhile:										; while jmps to here when condition is met to continue

; while (h > 0)									; while2 condition

while2:											
	mov eax, dword [rbp - 8]					; eax = h
	cmp eax, 0									; compares eax(h) to 0
	jle endwhile2								; if h is not greater than 0, jmp to end (done with while loop)

; while2 body

; first forloop

; set i variable

	mov r10, 0									; set r8 to 0
	mov r10d, dword [rbp - 8]					; r8d(i) = h
	dec r10										; i = h - 1

forloop1:

; set condition for the forloop

	cmp r10d, esi						        ; compares r8d(i) to the length(200)
	jge while2bodyEnd							; if i is greater than length, jmp to finish end of while2body

; forloop1 body

; tmp = lst[i]
	
	mov eax, dword [rdi + r10 * 4]				; eax = lst[i]
	mov dword [rbp - 4], eax					; tmp = lst[i]

; j = i
	mov r11, 0									; set r10 to 0
	mov r11d, r10d								; r10d(j) = r8d(i)
												; j = i

; set condition for forloop2

; if ((j < h) and (lst[j-h]) < tmp) then done with this loop, jmp out and finish forloop1 body

; forloop2 starts

forloop2:

; set the first condition of forloop2

condition1:
	mov eax, dword [rbp - 8]					; eax = h
	cmp r11d, eax								; compares r10d(j) to eax(h)
	jl  forloop1update							; if j is less than h, jump back out to forloop1 or cond2

; set the second condition of forloop2

condition2:

; create variable for (j-h)

	mov eax, dword [rbp - 8]					; eax = h
	mov r12d, r11d								; r11d = r10d(j)
	sub r12d, eax								; r11d - h = (j-h)
												; r11d = (j-h)
	
	mov eax, dword [rbp - 4]
	cmp dword [rdi + r12 * 4], eax			    ; compares lst[j-h] to eax(tmp)
	jle forloop1update							; if lst[j-h] is not greater than tmp, jump to finish forloop2 body

; forloop2 body

forloop2body:
	mov r13, 0									; set r12 to 0
	mov r13d, dword [rdi + r12 * 4]				; r12d = lst[j-h]
	mov dword [rdi + r11 * 4], r13d				; lst[j] = lst[j-h]

; update the loop variable (j = j-h)

	mov r11d, r12d								; j = j-h	
	jmp forloop2								; loop back to beginning of forloop2

; finish forloop1 body

; lst[j] = tmp

forloop1update:
	mov r14, 0									; set r13 to 0
	mov r14d, dword [rbp - 4]					; r13d = tmp
	mov dword [rdi + r11 * 4], r14d				; lst[j] = tmp

; update loop variable (i++)
	inc r10d									; i++
	jmp forloop1								; once finished with forloop1 body, jmp back to forloop1 beginning 

while2bodyEnd:
	mov eax, dword [rbp - 8]
	mov ebx, 3									; esi = 3 (to divide)
	div ebx										; eax = eax(h) / rsi(3)
	mov dword [rbp - 8], eax					; (updated h) h = h / 3
	mov edx, 0
	jmp while2

; end of while2 loop

endwhile2:

    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
; -----------------------------------------------------------------------------
;  Find basic statistical information for a list of integers:
;	minimum, median, maximum, sum, and average

;  Note, for an odd number of items, the median value is defined as
;  the middle value.  For an even number of values, it is the integer
;  average of the two middle values.

;  This function must call the lstSum() and lstAvergae() functions
;  to get the corresponding values.

;  Note, assumes the list is already sorted.

; -----
;  HLL Call:
;	call basicStats(list, len, min, med, max, sum, ave)

;  Returns:
;	minimum, median, maximum, sum, and average
;	via pass-by-reference (addresses on stack)

global basicStats
basicStats:


;	YOUR CODE GOES HERE

; prologue

	push rbp
	mov  rbp, rsp
	push r12
	mov  r12, 0

; get min

	mov eax, dword [rdi + r12 * 4]  			; puts the value of the last element into eax
	mov dword [rdx], eax						; puts eax into the min variable (r8)

; get median

	mov rax, rsi								; puts the length into rax
	mov rdx, 0									; sets upper order rdx to 0 (for dividing unsigned)
	mov r12d, 2									; puts 2 into r12 for dividing
	cdq
	idiv r12d									; rax = length / 2

	cmp rdx, 0									; checks for remainder (even or odd list)
	je evenLength								; if even jump to evenLength loop

	mov r12d, dword [rdi + rax * 4]				; r12d = lst[len/2]
	mov dword [rcx], r12d						; puts that value into the median variable (rcx)
	jmp medDone

evenLength:
	mov r12d, dword [rdi + rax * 4]				; r12d = lst[len/2]
	dec rax										; rax  = length / 2 - 1
	add r12d, dword [rdi + rax * 4]				; r12d = lst[len/2] + lst[len/2-1]
	mov eax, r12d								; rax = lst[len/2]
	mov r12d, 2									; mov 2 into r12 for dividing
	cdq
	idiv r12d									; rax = both list values / 2 = median
	mov dword [rcx], eax						; mov the median into the med variable (rcx)

medDone:
	
; get max
	mov r12, rsi
	dec r12
	mov eax, dword [rdi + r12 * 4]				; puts the first element of the (sorted) list into eax
	mov dword [r8], eax							; puts eax into the max variable (rdx)

; get sum

	call lstSum									; calls the sum function

; get average

	call lstAve									; calls the average function

	mov r12, qword [rbp + 16]
	mov dword [r12], eax

; epilogue

	pop r12										; pop anything that was pushed
	mov rsp, rbp
    pop rbp
	ret
; -----------------------------------------------------------------------------
;  Function to calculate the sum of a list.

; -----
;  Call:
;	ans = lstSum(lst, len)

;  Arguments Passed:
;	1) list, address
;	2) length, value

;  Returns:
;	sum (in eax)

;	YOUR CODE GOES HERE

global	lstSum
lstSum:

	push r12
	mov r12, 0
	mov rax, 0

sumloop:
	add eax, dword [rdi + r12 * 4]
	inc r12
	cmp r12, rsi
	jl sumloop
	mov dword [r9], eax
	pop r12

	ret


; -----------------------------------------------------------------------------
;  Function to calculate the average of a list.
;  Note, must call the lstSum() fucntion.

; -----
;  Call:
;	ans = lstAve(lst, len)

;  Arguments Passed:
;	1) list, address
;	2) length, value

;  Returns:
;	average (in eax)

;	YOUR CODE GOES HERE

global	lstAve
lstAve:

	call lstSum
	mov eax, dword [r9]
	cdq
	idiv esi

	ret


; -----------------------------------------------------------------------------
;  Function to calculate the linear regression
;  between two lists (of equal size).

; -----
;  Call:
;	linearRegression(xList, yList, len, xAve, yAve, b0, b1)

;  Arguments Passed:
;	1) xList, address
;	2) yList, address
;	3) length, value
;	4) xList average, value
;	5) yList average, value
;	6) b0, address
;	7) b1, address

;  Returns:
;	b0 and b1 via reference



;	YOUR CODE GOES HERE

global linearRegression
linearRegression:

; prologue

	push rbp								; push rbp first when handling stack based arguments
	mov rbp, rsp
    ; sub rsp, 12
	push rbx
	mov rbx, 0
	push r12
	mov r12, 0
	push r11
	push r10
	mov r10, 0
	push r13
	mov r13d, edx
	mov rax, 0
	push r14
	push r15

; get linear regression values

sumBottomLoop:
	mov eax, dword [rdi + r12 * 4]			
	sub eax, ecx
	imul eax
	shl rdx, 32
	add rdx, rax
	add r14, rdx
	inc r12
	cmp r12, r13
	jne sumBottomLoop

	; mov rbx, r14

	mov r12, 0
sumTopLoop:
	mov eax, dword [rdi + r12 * 4]
	sub eax, ecx
	mov r11d, dword [rsi + r12 * 4]
	sub r11d, r8d
	imul r11d
	shl rdx, 32
	add rdx, rax
	add r15, rdx
	inc r12
	cmp r12, r13
	jne sumTopLoop

; division of top and bottom (b1)

	mov rax, r15
	cqo
	idiv r14

	mov r10, qword [rbp + 16]
	mov dword [r10], eax

; calculate b0

	imul ecx
	sub  r8, rax

	mov dword [r9], r8d

	mov qword [rbp - 16], 0
	mov qword [rbp - 8], 0

	pop r15
	pop r14
	pop r13
	pop r10
	pop r11
	pop r12
	pop rbx
    mov rsp, rbp
	pop rbp

	ret

; -----------------------------------------------------------------------------

