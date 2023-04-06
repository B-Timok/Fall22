;  Name: Brandon Timok
;  Description: arithmetic instructions, control instructions, compare instructions, and
;               conditional jump instructions.


; *****************************************************************
section	.data

; -----
;  Define constants.

NULL		equ	0			; end of string

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; successful operation
SYS_exit	    equ	60			; call code for terminate

; -----

; data declarations

lst		    dd	4224, 1116, 1542, 1240, 1677
            dd	1635, 2420, 1820, 1246, 1333 
            dd	2315, 1215, 2726, 1140, 2565
            dd	2871, 1614, 2418, 2513, 1422 
            dd	1119, 1215, 1525, 1712, 1441
            dd	3622, 1731, 1729, 1615, 2724 
            dd	1217, 1224, 1580, 1147, 2324
            dd	1425, 1816, 1262, 2718, 1192 
            dd	1435, 1235, 2764, 1615, 1310
            dd	1765, 1954, 1967, 1515, 1556 
            dd	1342, 7321, 1556, 2727, 1227
            dd	1927, 1382, 1465, 3955, 1435 
            dd	1225, 2419, 2534, 1345, 2467
            dd	1615, 1959, 1335, 2856, 2553 
            dd	1035, 1833, 1464, 1915, 1810
            dd	1465, 1554, 1267, 1615, 1656 
            dd	2192, 1825, 1925, 2312, 1725
            dd	2517, 1498, 1677, 1475, 2034 
            dd	1223, 1883, 1173, 1350, 2415
            dd	1335, 1125, 1118, 1713, 3025

length		dd	100

lstMin		dd	0
estMed		dd	0
lstMax		dd	0
lstSum		dd	0
lstAve		dd	0

oddCnt		dd	0
oddSum		dd	0
oddAve		dd	0

nineCnt		dd	0
nineSum		dd	0
nineAve		dd	0

; *****************************************************************

section	.text
global _start
_start:

; **********************************************

; Compute minimum of lst

; loop
; if (lst[i] < lstMin)
;    lstMin = lst[i];

    mov eax, dword [lst]
    mov dword [lstMin], eax
    mov rsi, 0
    mov ecx, dword [length]

MinLoop:
    mov eax, dword [lst + rsi * 4]
    cmp eax, dword [lstMin]
    jae MinDone
    mov dword [lstMin], eax

MinDone:
    inc rsi
    loop MinLoop              ; decrements ecx, then compares ecx to 0, then jumps to the label.

; *****

; Compute the estimated median of lst

; first   = lst[0]
; last    = lst[lenth - 1]
; middle  = lst[length / 2]
; middle2 = lst[(length / 2) - 1]
; median  = (first + last + middle + middle2) / 4

;   add first to estMed

    mov eax, dword [lst]
    mov dword [estMed], eax

;   add last to estMed

    mov rsi, 0
    mov esi, dword [length]
    dec rsi
    mov edx, dword [lst + rsi * 4]
    add dword [estMed], edx

;   add middle to estMed
    
    mov eax, dword [length]
    mov edx, 0
    mov ebx, 2
    div ebx
    mov edx, dword [lst + eax * 4]
    add dword [estMed], edx

;   add middle2 to estMed

    mov edx, 0
    dec eax
    mov edx, dword [lst + eax * 4]
    add dword [estMed], edx

;   divide estMed by 4

    mov eax, 0
    mov eax, dword [estMed]
    mov edx, 0
    mov ebx, 4
    div ebx
    mov dword [estMed], eax

; *****

; Compute maximum of lst

; loop
; if (lst[i] > lstMax)
;   lstMax = lst[i]

    mov eax, dword [lst]
    mov dword [lstMax], eax
    mov rsi, 0
    mov ecx, dword [length]

MaxLoop:
    mov eax, dword [lst + rsi * 4]
    cmp eax, dword [lstMax]
    jbe MaxDone
    mov dword [lstMax], eax

MaxDone:
    inc rsi
    loop MaxLoop

; *****

; Compute sum of the lst

; iterate through and add each time

    mov eax, dword [lst]
    mov dword [lstSum], eax
    mov rsi, 1
    mov ecx, dword [length]
    dec ecx

SumLoop:
    mov eax, dword [lst + rsi * 4]
    add dword [lstSum], eax
    inc rsi
    loop SumLoop                        ; dec ecx, cmp ecx, 0, jne Sumloop

; *****

; Compute the average of the lst of numbers

; divide the sum by the length

    mov eax, dword [lstSum]
    mov edx, 0
    div dword [length]
    mov dword [lstAve], eax

; *****

; Compute the count of the odd numbers of the lst

    mov ecx, dword [length]
    mov rsi, 0

OddCountLoop:

    mov eax, dword [lst + rsi * 4]
    mov edx, 0
    mov ebx, 2
    div ebx
    inc rsi
    dec ecx
    cmp edx, 1
    jne OddCountLoop
    inc dword [oddCnt]
    cmp ecx, 0
    jne OddCountLoop

; *****

; Compute the sum of the odd numbers of the lst

    mov ecx, dword [length]
    mov rsi, 0

OddSumLoop:

    mov eax, dword [lst + rsi * 4]
    mov edi, dword [lst + rsi * 4]
    mov edx, 0
    mov ebx, 2
    div ebx
    inc rsi
    dec ecx
    cmp edx, 1
    jne OddSumLoop
    add dword [oddSum], edi
    cmp ecx, 0
    jne OddSumLoop

; *****

; Compute the average of the odd numbers of the lst

; divide odd sum by the odd count to get the average

    mov eax, dword [oddSum]
    mov edx, 0
    div dword [oddCnt]
    mov dword [oddAve], eax

; *****

; Compute the count of numbers that are evenly divisible by 9 in the lst

; loop
; if lst[i] % 9 = 0
;   inc nineCnt
; else go to next element

    mov ecx, dword [length]
    mov rsi, 0

Count9:
    cmp ecx, 0
    je Count9End
    mov edx, 0
    mov eax, dword [lst + rsi * 4]
    mov ebx, 9
    div ebx
    inc rsi
    dec ecx
    cmp edx, 0
    jne Count9
    inc dword [nineCnt]
    cmp ecx, 0
    jne Count9

Count9End:

; *****

; Computes the sum of the numbers in the list that are divisible by 9 evenly

; same approach as count, but saving and adding the numbers as we count

    mov ecx, dword [length]
    mov rsi, 0

SumCount9:
    
    cmp ecx, 0
    je  SumCount9End
    mov eax, dword [lst + rsi * 4]
    mov edi, dword [lst + rsi * 4]
    mov edx, 0
    mov ebx, 9
    div ebx
    inc rsi
    dec ecx
    cmp edx, 0
    jne SumCount9
    add dword [nineSum], edi
    cmp ecx, 0
    jne SumCount9

SumCount9End:

; *****

; Compute the average of the sum of numbers in the list that divide by nine evenly

    mov eax, dword [nineSum]
    mov edx, 0
    div dword [nineCnt]
    mov dword [nineAve], eax

; **********************************************

;	Done, terminate program.

last:
	mov	rax, SYS_exit		; call call for exit (SYS_exit)
	mov	rdi, EXIT_SUCCESS	; return code of 0 (no error)
	syscall
