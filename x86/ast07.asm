; *****************************************************************
;  Name: Brandon Timok
;  Description:	Sort a list of numbers using the shell sort
;		algorithm.  Also finds the minimum, median, 
;		maximum, and average of the list.

; -----
; Shell Sort

;	h = 1;
;       while ( (h*3+1) < a.length) {
;	    h = 3 * h + 1;
;	}

;       while( h > 0 ) {
;           for (i = h-1; i < a.length; i++) {
;               tmp = a[i];
;               j = i;
;               for( j = i; (j >= h) && (a[j-h] > B); j -= h) {
;                   a[j] = a[j-h];
;               }
;               a[j] = tmp;
;           }
;           h = h / 3;
;       }

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
;  Data Declarations.

section	.data

; -----
;  Define constants.

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; Successful operation

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
NULL		equ	0
ESC		equ	27

; -----
;  Provided data

lst	dd	1113, 1232, 2146, 1376, 5120, 2356,  164, 4565, 155, 3157
	dd	 759, 326,  171,  147, 5628, 7527, 7569,  177, 6785, 3514
	dd	1001,  128, 1133, 1105,  327,  101,  115, 1108,    1,  115
	dd	1227, 1226, 5129,  117,  107,  105,  109,  999,  150,  414
	dd	 107, 6103,  245, 6440, 1465, 2311,  254, 4528, 1913, 6722
	dd	1149,  126, 5671, 4647,  628,  327, 2390,  177, 8275,  614
	dd	3121,  415,  615,  122, 7217,    1,  410, 1129,  812, 2134
	dd	 221, 2234,  151,  432,  114, 1629,  114,  522, 2413,  131
	dd	5639,  126, 1162,  441,  127,  877,  199,  679, 1101, 3414
	dd	2101,  133, 1133, 2450,  532, 8619,  115, 1618, 9999,  115
	dd	 219, 3116,  612,  217,  127, 6787, 4569,  679,  675, 4314
	dd	1104,  825, 1184, 2143, 1176,  134, 4626,  100, 4566,  346
	dd	1214, 6786,  617,  183,  512, 7881, 8320, 3467,  559, 1190
	dd	 103,  112,    1, 2186,  191,   86,  134, 1125, 5675,  476
	dd	5527, 1344, 1130, 2172,  224, 7525,  100,    1,  100, 1134   
	dd	 181,  155, 1145,  132,  167,  185,  150,  149,  182,  434
	dd	 581,  625, 6315,    1,  617,  855, 6737,  129, 4512,    1
	dd	 177,  164,  160, 1172,  184,  175,  166, 6762,  158, 4572
	dd	6561,  283, 1133, 1150,  135, 5631, 8185,  178, 1197,  185
	dd	 649, 6366, 1162,  167,  167,  177,  169, 1177,  175, 1169

lst2    dd      6, 10, 4, 5, 7

len2    dd      5

len	dd	200

min	dd	0
med	dd	0
max	dd	0
sum	dd	0
avg	dd	0


; -----
;  Misc. data definitions (if any).

h		dd	0
i		dd	0
j		dd	0
tmp		dd	0


; -----
;  Provided string definitions.

STR_LENGTH	equ	12			; chars in string, with NULL

newLine		db	LF, NULL

hdr		db	"---------------------------"
		db	"---------------------------"
		db	LF, ESC, "[1m", "CS 218 - Assignment #7", ESC, "[0m"
		db	LF, "Shell Sort", LF, LF, NULL

hdrMin		db	"Minimum:  ", NULL
hdrMed		db	"Median:   ", NULL
hdrMax		db	"Maximum:  ", NULL
hdrSum		db	"Sum:      ", NULL
hdrAve		db	"Average:  ", NULL

; ---------------------------------------------

section .bss

tmpString	resb	STR_LENGTH

; ---------------------------------------------

section	.text
global	_start
_start:

; ******************************
;  Shell Sort.
;  Find sum and compute the average.
;  Get/save min and max.
;  Find median.


;	YOUR CODE GOES HERE

; h = 1

	mov eax, dword [h]							; eax = h = 0
	inc eax										; eax = 1
	mov dword [h], eax							; h = 1

; while ( (h*3+1) < a.length )

; condition for while 

while:
	mov eax, dword [h]
	mov rsi, 3									; rsi = 3
	mul rsi										; eax * rsi = (3 * 1) = 3
	inc eax										; 3 + 1 = 4
	cmp eax, dword [len]						; compares eax to length (4 < 200)
	jae endwhile								; if condition is met then done with while

; while body { h = 3 * h + 1; }

whilebody:
	mov eax, dword [h]							; eax = h
	mul rsi										; eax * rsi = (h * 3) = eax
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

	cmp r8d, dword [len]						; compares r8d(i) to the length(200)
	jae while2bodyEnd							; if i is greater than length, jmp to finish end of while2body

; forloop1 body

; tmp = lst[i]
	
	mov eax, dword [lst + r8d * 4]				; eax = lst[i]
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
	cmp dword [lst + r11d * 4], eax			; compares lst[j-h] to eax(tmp)
	jbe forloop1update							; if lst[j-h] is not greater than tmp, jump to finish forloop2 body

; forloop2 body

forloop2body:
	mov r12, 0									; set r12 to 0
	mov r12d, dword [lst + r11d * 4]			; r12d = lst[j-h]
	mov dword [lst + r10d * 4], r12d			; lst[j] = lst[j-h]

; update the loop variable (j = j-h)

	mov r10d, r11d								; j = j-h	
	jmp forloop2								; loop back to beginning of forloop2

; finish forloop1 body

; lst[j] = tmp

forloop1update:
	mov r13, 0									; set r13 to 0
	mov r13d, dword [tmp]						; r13d = tmp
	mov dword [lst + r10d * 4], r13d			; lst[j] = tmp

; update loop variable (i++)
	inc r8d										; i++
	jmp forloop1								; once finished with forloop1 body, jmp back to forloop1 beginning 

while2bodyEnd:
	mov eax, dword [h]
	mov esi, 3									; esi = 3 (to divide)
	div esi										; eax = eax(h) / rsi(3)
	mov dword [h], eax							; (updated h) h = h / 3
	mov edx, 0
	jmp while2

; end of while2 loop

endwhile2:

; calculation min of list

	mov eax, dword [lst]
	mov dword [min], eax
	mov rsi, 0
	mov ecx, dword [len]

minloop:
	mov eax, dword [lst + rsi * 4]
	cmp dword [min], eax
	jle minDone
	mov dword [min], eax

minDone:
	inc rsi
	loop minloop

; calculation of median of list

	mov eax, dword [len]
	mov esi, 2
	div esi
	mov ebx, dword [lst + eax * 4]
	dec eax
	add ebx, dword [lst + eax * 4]
	mov eax, ebx
	div esi
	mov dword [med], eax

; calculation of max of list

	mov eax, dword [lst]
	mov dword [max], eax
	mov rsi, 0
	mov ecx, dword [len]

maxloop:
	mov eax, dword [lst + rsi * 4]
	cmp dword [max], eax
	jge maxDone
	mov dword [max], eax

maxDone:
	inc rsi 
	loop maxloop

; calculation of the sum of the list

	mov eax, dword [lst]
	mov dword [sum], eax
	mov rsi, 1
	mov ecx, dword [len]
	dec ecx

sumloop:
	mov eax, dword [lst + rsi * 4]
	add dword [sum], eax
	inc rsi
	loop sumloop

; calculation for the average of the list

	mov eax, dword [sum]
	mov esi, dword [len]
	div esi
	mov dword [avg], eax

; ******************************
;  Display results to screen in septenary.

	printString	hdr

	printString	hdrMin
	int2aSept	dword [min], tmpString
	printString	tmpString
	printString	newLine

	printString	hdrMed
	int2aSept	dword [med], tmpString
	printString	tmpString
	printString	newLine

	printString	hdrMax
	int2aSept	dword [max], tmpString
	printString	tmpString
	printString	newLine

	printString	hdrSum
	int2aSept	dword [sum], tmpString
	printString	tmpString
	printString	newLine

	printString	hdrAve
	int2aSept	dword [avg], tmpString
	printString	tmpString
	printString	newLine
	printString	newLine

; ******************************
;  Done, terminate program.

last:
	mov	rax, SYS_exit
	mov	rdi, EXIT_SUCCESS
	syscall

