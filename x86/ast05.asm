;  Name: Brandon Timok
;  Description: Program to find the minimum, maximum, estimated median, sum, and average for
;               the volumes and surface areas.
               


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
;  Provided Data

lengths		dd	 1355,  1037,  1123,  1024,  1453
            dd	 1115,  1135,  1123,  1123,  1123
            dd	 1254,  1454,  1152,  1164,  1542
            dd	-1353,  1457,  1182, -1142,  1354
            dd	 1364,  1134,  1154,  1344,  1142
            dd	 1173, -1543, -1151,  1352, -1434
            dd	 1134,  2134,  1156,  1134,  1142
            dd	 1267,  1104,  1134,  1246,  1123
            dd	 1134, -1161,  1176,  1157, -1142
            dd	-1153,  1193,  1184,  1142

widths		dw	  367,   316,   542,   240,   677
            dw	  635,   426,   820,   146,  -333
            dw	  317,  -115,   226,   140,   565
            dw	  871,   614,   218,   313,   422	
            dw	 -119,   215,  -525,  -712,   441
            dw	 -622,  -731,  -729,   615,   724
            dw	  217,  -224,   580,   147,   324
            dw	  425,   816,   262,  -718,   192
            dw	 -432,   235,   764,  -615,   310
            dw	  765,   954,  -967,   515

heights		db	   42,    21,    56,    27,    35
            db	  -27,    82,    65,    55,    35
            db	  -25,   -19,   -34,   -15,    67
            db	   15,    61,    35,    56,    53
            db	  -32,    35,    64,    15,   -10
            db	   65,    54,   -27,    15,    56
            db	   92,   -25,    25,    12,    25
            db	  -17,    98,   -77,    75,    34
            db	   23,    83,   -73,    50,    15
            db	   35,    25,    18,    13

length		dd	49

vMin		dd	0
vEstMed		dd	0
vMax		dd	0
vSum		dd	0
vAve		dd	0

saMin		dd	0
saEstMed	dd	0
saMax		dd	0
saSum		dd	0
saAve		dd	0

; -----
; Additional variables (if any)

count       dd  49
SAdim1      dd  0
SAdim2      dd  0
SAdim3      dd  0

; --------------------------------------------------------------
; Uninitialized data

section	.bss

volumes		    resd	49
surfaceAreas	resd	49

; *****************************************************************

section	.text
global _start
_start:

; **********************************************

; Compute the volumes of the rectangular solids

; volumes[n] = lengths[n] * widths[n] * heights[n]

    mov ecx, dword [length]
    mov rsi, 0

VolumeLoop:
    mov eax, dword [lengths + rsi * 4]
    movsx ebx, word [widths + rsi * 2]                  ; sign extend to convert small into big
    imul ebx
    movsx edi, byte [heights + rsi]                     ; sign extend conversion
    imul edi
    mov dword [volumes + rsi * 4], eax
    inc rsi
    dec ecx                                             ; can use loop instruction here
    cmp ecx, 0
    jne VolumeLoop

; *****

; Compute the surface areas of each rectangular solids

; surfaceAreas[n] = (2 * lengths[n] * widths[n]) + (2 * lengths[n] * heights[n])
;                    + (2 * widths[n] * heights[n])

    mov ecx, dword [length]
    mov rsi, 0

SALoop:
    mov eax, dword [lengths + rsi * 4]
    movsx ebx, word [widths + rsi * 2]
    imul ebx
    imul eax, 2 
    mov dword [SAdim1], eax
    mov eax, dword [lengths + rsi * 4]
    movsx ebx, byte [heights + rsi]
    imul ebx
    imul eax, 2
    mov dword [SAdim2], eax
    movsx eax, word [widths + rsi * 2]
    movsx ebx, byte [heights + rsi]
    imul ebx
    imul eax, 2
    mov dword [SAdim3], eax
    mov r8d, dword [SAdim1]
    add r8d, dword [SAdim2]
    add r8d, dword [SAdim3]
    mov dword [surfaceAreas + rsi * 4], r8d
    inc rsi
    dec ecx
    cmp ecx, 0
    jne SALoop

; *****

; Compute the minimum of the volumes

; if volumes[n] < vMin
;   vMin = volumes[n]

    mov eax, dword [volumes]
    mov dword [vMin], eax
    mov rsi, 0
    mov ecx, dword [length]

minLoop:
    mov eax, dword [volumes + rsi * 4]
    cmp eax, dword [vMin]
    jge MinDone
    mov dword [vMin], eax

MinDone:
    inc rsi
    loop minLoop

; *****

; Compute the minimum for the surfaceAreas

    mov eax, dword [surfaceAreas]
    mov dword [saMin], eax
    mov rsi, 0
    mov ecx, dword [length]

minLoopSA:
    mov eax, dword [surfaceAreas + rsi * 4]
    cmp eax, dword [saMin]
    jge minDoneSA
    mov dword [saMin], eax

minDoneSA:
    inc rsi
    loop minLoopSA



; *****

; Compute the maximum of the volumes

; if volumes[n] > vMax
;   vMax = volumes[n]

    mov eax, dword [volumes]
    mov dword [vMax], eax
    mov rsi, 0
    mov ecx, dword [length]

maxloop:
    mov eax, dword [volumes + rsi * 4]
    cmp eax, dword [vMax]
    jle MaxDone
    mov dword [vMax], eax
    

MaxDone:
    inc rsi
    dec ecx
    cmp ecx, 0
    jne maxloop

; *****

; Compute the maximim for the surfaceAreas

    mov eax, dword [surfaceAreas]
    mov dword [saMax], eax
    mov rsi, 0
    mov ecx, dword [length]

maxloopSA:
    mov eax, dword [surfaceAreas + rsi * 4]
    cmp eax, dword [saMax]
    jle maxDoneSA
    mov dword [saMax], eax

maxDoneSA:
    inc rsi
    loop maxloopSA

; Compute the estimated median of the volumes

; estimated median is the (first number + last number + middle number(s)) / amount of numbers

; add first element to the variable for the estimated median

    mov eax, dword [volumes]
    mov dword [vEstMed], eax

; add last element to estMed

    mov esi, dword [length]
    dec esi
    mov eax, dword [volumes + esi * 4]
    add dword [vEstMed], eax

; since odd number of elements, add middle to estmed (length / 2)

    mov eax, dword [length]
    cdq
    mov esi, 2
    idiv esi
    mov ebx, dword [volumes + eax * 4]
    add dword [vEstMed], ebx

; divide them all by 3 for the estimated median

; volumes median

    mov eax, dword [vEstMed]
    cdq
    mov esi, 3
    idiv esi
    mov dword [vEstMed], eax

; *****

; surfaceAreas estimated median

; add first element to the variable for the estimated median

    mov eax, dword [surfaceAreas]
    mov dword [saEstMed], eax

; add last element to estMed

    mov esi, dword [length]
    dec esi
    mov eax, dword [surfaceAreas + esi * 4]
    add dword [saEstMed], eax

; since odd number of elements, add middle to estmed (length / 2)

    mov eax, dword [length]
    cdq
    mov esi, 2
    idiv esi
    mov ebx, dword [surfaceAreas + eax * 4]
    add dword [saEstMed], ebx

; divide them all by 3 for the estimated median

; volumes median

    mov eax, dword [saEstMed]
    cdq
    mov esi, 3
    idiv esi
    mov dword [saEstMed], eax


; *****

; Compute the sum of the volumes and surfaceAreas

; add each element by iterating through

    mov eax, dword [volumes]
    mov ebx, dword [surfaceAreas]
    mov dword [vSum], eax
    mov dword [saSum], ebx
    mov rsi, 1
    mov ecx, dword [length]
    dec ecx

sumloopV:
    mov eax, dword [volumes + rsi * 4]
    mov ebx, dword [surfaceAreas + rsi * 4]
    add dword [vSum], eax
    add dword [saSum], ebx
    inc rsi
    dec ecx
    cmp ecx, 0
    jne sumloopV

; *****

; Compute the average of the volumes

; divide the sum by the number of elements

    mov eax, dword [vSum]
    cdq
    mov esi, dword [length]
    idiv esi
    mov dword [vAve],  eax

; do the same to find the average of the surfaceAreas

    mov eax, dword [saSum]
    cdq
    idiv esi
    mov dword [saAve], eax








    






; **********************************************

;	Done, terminate program.

last:
	mov	rax, SYS_exit		; call call for exit (SYS_exit)
	mov	rdi, EXIT_SUCCESS	; return code of 0 (no error)
	syscall
