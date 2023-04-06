; *****************************************************************
;  Name: Brandon Timok
;  Description: Program to call functions computing the min, max, med, sum, and ave of lists.


; -----------------------------------------------------------------
;  Write some assembly language functions.

;  The function, shellSort(), sorts the numbers into descending
;  order (large to small).

;  The function, basicStats(), finds the minimum, median, and maximum,
;  sum, and average for a list of numbers.
;  Note, the median is determined after the list is sorted.
;	This function must call the lstSum() and lstAvergae()
;	functions to get the corresponding values.
;	The lstAvergae() function must call the lstSum() function.

;  The function, linearRegression(), computes the linear regression of
;  the two data sets.  Summation and division performed as integer.

; *****************************************************************

section	.data

; -----
;  Define constants.

TRUE		equ	1
FALSE		equ	0

; -----
;  Local variables for shellSort() function (if any).

h		dd	0
i		dd	0
j		dd	0
tmp		dd	0

; -----
;  Local variables for basicStats() function (if any).


; -----------------------------------------------------------------

section	.bss

; -----
;  Local variables for linearRegression() function (if any).

qSum		resq	1
dSum		resd	1


; *****************************************************************

section	.text

; --------------------------------------------------------
;  Shell sort function (form asst #7).
;	Updated to sort in descending order.

; -----
;  HLL Call:
;	call shellSort(list, len)

;  Arguments Passed:
;	1) list, addr - rdi
;	2) length, value - rsi

;  Returns:
;	sorted list (list passed by reference)

global	shellSort
shellSort:


;	YOUR CODE GOES HERE

; h = 1

	mov eax, dword [h]							; eax = h = 0
	inc eax										; eax = 1
	mov dword [h], eax							; h = 1

; while ( (h*3+1) < a.length )

; condition for while 

while:
	mov eax, dword [h]
	mov rcx, 3									; rsi = 3
	mul rcx										; eax * rsi = (3 * 1) = 3
	inc eax										; 3 + 1 = 4
	cmp rax, rsi								; compares eax to length (4 < 200)
	jae endwhile								; if condition is met then done with while

; while body { h = 3 * h + 1; }

whilebody:
	mov eax, dword [h]							; eax = h
	mul rcx										; eax * rsi = (h * 3) = eax
	inc eax										; eax + 1 = (h * 3 + 1)
	mov dword [h], eax							; h = h * 3 + 1
	jmp while									; back to condition for while with updated (h)

; for when the condition is met

endwhile:										; while jmps to here when condition is met to continue

; while (h > 0)									; while2 condition

while2:											
	mov eax, dword [h]							; eax = h
	cmp eax, 0									; compares eax(h) to 0
	jbe endwhile2								; if h is not greater than 0, jmp to end (done with while loop)

; while2 body

; first forloop

; set i variable

	mov r8, 0									; set r8 to 0
	mov r8d, dword [h]							; r8d(i) = h
	dec r8										; i = h - 1

forloop1:

; set condition for the forloop

	cmp r8, rsi									; compares r8d(i) to the length(200)
	jae while2bodyEnd							; if i is greater than length, jmp to finish end of while2body

; forloop1 body

; tmp = lst[i]
	
	mov eax, dword [rdi + r8 * 4]				; eax = lst[i]
	mov dword [tmp], eax						; tmp = lst[i]

; j = i
	mov r10, 0									; set r10 to 0
	mov r10d, r8d								; r10d(j) = r8d(i)
												; j = i

; set condition for forloop2

; if ((j < h) and (lst[j-h]) < tmp) then done with this loop, jmp out and finish forloop1 body

; forloop2 starts

forloop2:

; set the first condition of forloop2

condition1:
	mov eax, dword [h]							; eax = h
	cmp r10d, eax								; compares r10d(j) to eax(h)
	jb  forloop1update							; if j is less than h, jump back out to forloop1 or cond2

; set the second condition of forloop2

condition2:

; create variable for (j-h)

	mov eax, dword [h]							; eax = h
	mov r11d, r10d								; r11d = r10d(j)
	sub r11d, eax								; r11d - h = (j-h)
												; r11d = (j-h)
	
	mov eax, dword [tmp]
	cmp dword [rdi + r11 * 4], eax				; compares lst[j-h] to eax(tmp)
	jge forloop1update							; if lst[j-h] is not greater than tmp, jump to finish forloop2 body

; forloop2 body

forloop2body:
	mov r12, 0									; set r12 to 0
	mov r12d, dword [rdi + r11 * 4]				; r12d = lst[j-h]
	mov dword [rdi + r10 * 4], r12d				; lst[j] = lst[j-h]

; update the loop variable (j = j-h)

	mov r10d, r11d								; j = j-h	
	jmp forloop2								; loop back to beginning of forloop2

; finish forloop1 body

; lst[j] = tmp

forloop1update:
	mov r13, 0									; set r13 to 0
	mov r13d, dword [tmp]						; r13d = tmp
	mov dword [rdi + r10 * 4], r13d				; lst[j] = tmp

; update loop variable (i++)
	inc r8d										; i++
	jmp forloop1								; once finished with forloop1 body, jmp back to forloop1 beginning 

while2bodyEnd:
	mov eax, dword [h]
	mov ecx, 3									; esi = 3 (to divide)
	div ecx										; eax = eax(h) / rcx(3)
	mov dword [h], eax							; (updated h) h = h / 3
	mov edx, 0
	jmp while2

; end of while2 loop

endwhile2:

	ret

; --------------------------------------------------------
;  Find basic statistical information for a list of integers:
;	minimum, median, maximum, sum, and average

;  Note, for an odd number of items, the median value is defined as
;  the middle value.  For an even number of values, it is the integer
;  average of the two middle values.

;  This function must call the lstSum() and lstAvergae() functions
;  to get the corresponding values.

;  Note, assumes the list is already sorted.

; -----
;  Call:
;	call basicStats(list, len, min, med, max, sum, ave)

;  Arguments Passed:
;	1) list, addr - rdi
;	2) length, value - rsi
;	3) minimum, addr - rdx
;	4) median, addr - rcx
;	5) maximum, addr - r8
;	6) sum, addr - r9
;	7) ave, addr - stack, rbp+16

;  Returns:
;	minimum, median, maximum, sum, and average
;	via pass-by-reference (addresses on stack)

global basicStats
basicStats:


;	YOUR CODE GOES HERE

; prologue

	push rbp
	mov rbp, rsp
	push r12

; get min

	mov r12, rsi							; puts the length into r12
	dec r12									; r12 = len - 1 (last element of list)
	mov eax, dword [rdi + r12 * 4]  		; puts the value of the last element into eax
	mov dword [rdx], eax					; puts eax into the min variable (r8)

; get median

	mov rax, rsi							; puts the length into rax
	mov rdx, 0								; sets upper order rdx to 0 (for dividing unsigned)
	mov r12d, 2								; puts 2 into r12 for dividing
	cdq
	idiv r12d								; rax = length / 2

	cmp rdx, 0								; checks for remainder (even or odd list)
	je evenLength							; if even jump to evenLength loop

	mov r12d, dword [rdi + rax * 4]			; r12d = lst[len/2]
	mov dword [rcx], r12d					; puts that value into the median variable (rcx)
	jmp medDone

evenLength:
	mov r12d, dword [rdi + rax * 4]			; r12d = lst[len/2]
	dec rax									; rax  = length / 2 - 1
	add r12d, dword [rdi + rax * 4]			; r12d = lst[len/2] + lst[len/2-1]
	mov eax, r12d							; rax = lst[len/2]
	mov r12d, 2								; mov 2 into r12 for dividing
	cdq
	idiv r12d								; rax = both list values / 2 = median
	mov dword [rcx], eax					; mov the median into the med variable (rcx)

medDone:
	
; get max

	mov eax, dword [rdi]					; puts the first element of the (sorted) list into eax
	mov dword [r8], eax						; puts eax into the max variable (rdx)

; get sum

	call lstSum								; calls the sum function

; get average

	call lstAve								; calls the average function

	mov r12, qword [rbp + 16]
	mov dword [r12], eax

; epilogue

	pop r12									; pop anything that was pushed
	pop rbp
	ret

; --------------------------------------------------------
;  Function to calculate the sum of a list.

; -----
;  Call:
;	ans = lstSum(lst, len)

;  Arguments Passed:
;	1) list, address - rdi
;	1) length, value - rsi

;  Returns:
;	sum (in eax)


global	lstSum
lstSum:


;	YOUR CODE GOES HERE

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

; --------------------------------------------------------
;  Function to calculate the average of a list.
;  Note, must call the lstSum() fucntion.

; -----
;  Call:
;	ans = lstAve(lst, len)

;  Arguments Passed:
;	1) list, address - rdi
;	1) length, value - rsi

;  Returns:
;	average (in eax)


global	lstAve
lstAve:


;	YOUR CODE GOES HERE

	call lstSum
	mov eax, dword [r9]
	cdq
	idiv rsi

	ret

; --------------------------------------------------------
;  Function to calculate the linear regression
;  between two lists (of equal size).
;  Due to the data sizes, the summation for the dividend (top)
;  MUST be performed as a quad-word.

; -----
;  Call:
;	linearRegression(xList, yList, len, xAve, yAve, b0, b1)

;  Arguments Passed:
;	1) xList, address - rdi
;	2) yList, address - rsi
;	3) length, value - edx
;	4) xList average, value - ecx
;	5) yList average, value - r8d
;	6) b0, address - r9
;	7) b1, address - stack, rpb+16

;  Returns:
;	b0 and b1 via reference

global linearRegression
linearRegression:

;	YOUR CODE GOES HERE

; prologue

	push rbp								; push rbp first when handling stack based arguments
	mov rbp, rsp
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
	
	

	
; get linear regression values

sumBottomLoop:
	mov eax, dword [rdi + r12 * 4]			
	sub eax, ecx
	imul eax
	add dword [dSum], eax
	adc dword [dSum + 4], edx
	inc r12
	cmp r12, r13
	jne sumBottomLoop

	mov rbx, qword [dSum]

	mov r12, 0
sumTopLoop:
	mov eax, dword [rdi + r12 * 4]
	sub eax, ecx
	mov r11d, dword [rsi + r12 * 4]
	sub r11d, r8d
	imul r11d
	add dword [qSum], eax
	adc dword [qSum + 4], edx
	inc r12
	cmp r12, r13
	jne sumTopLoop

; division of top and bottom (b1)

	mov rax, qword [qSum]
	cqo
	idiv qword [dSum]

	mov r10, qword [rbp + 16]
	mov dword [r10], eax

; calculate b0

	imul ecx
	sub  r8, rax

	mov dword [r9], r8d

	mov qword [dSum], 0
	mov qword [qSum], 0

	pop r13
	pop r10
	pop r11
	pop r12
	pop rbx
	pop rbp

	ret

; ********************************************************************************

