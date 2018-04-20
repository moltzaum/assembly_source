
Include Irvine32.inc
Include inc_file.inc

.code

; Scan Codes
; http://www.ee.bgu.ac.il/~microlab/MicroLab/Labs/ScanCodes.htm
UP_SC    = 48h
DOWN_SC  = 50h
LEFT_SC  = 4Bh
RIGHT_SC = 4Dh
ENTER_SC = 1Ch
F_SC     = 21h

; accepts dh and dl
GotoClamp PROC,
	minX:BYTE,
	maxX:BYTE,
	minY:BYTE,
	maxY:BYTE

	cmp dh, minX
	jnl test_max ; clamp to min
		mov dh, minX
	jmp good
	test_max:
	cmp dh, maxX
	jnge good ; clamp to max
		mov dh, maxX
	good:

	cmp dl, minY
	jnl test_max2 ; clamp to min
		mov dl, minY
	jmp good2
	test_max2:
	cmp dl, maxY
	jnge good2 ; clamp to max
		mov dl, maxY
	good2:

	RET
GotoClamp ENDP

; handles arrowkey events
; if a flag or enter event is triggered,
; we return that along with the current
; goto data in dh, dl
; TODO change name for "KeyTest" to make more sense
KeyTest PROC
	
	push ebx

	KeyboardInput:
		push edx ; ReadKey affects edx
		call ReadKey
		pop edx

		jz end_readkey ; no data
		; al holds ascii data
		; ah holds scan codes
		cmp eax, 1 ; Has a key been pressed?
		je end_readkey
			
			; ARROW KEYS
			cmp ah, UP_SC
			jne cmp1
				dec dh
				call GotoXY
			jmp end_cmp
			cmp1:
			cmp ah, DOWN_SC
			jne cmp2
				inc dh
				call GotoXY
			jmp end_cmp
			cmp2:
			cmp ah, LEFT_SC
			jne cmp3
				add dl, -2
				call GotoXY
			jmp end_cmp
			cmp3:
			cmp ah, RIGHT_SC
			jne cmp4
				add dl, 2
				call GotoXY
			jmp end_cmp
			cmp4:
			cmp ah, ENTER_SC
			jne cmp5
				mov al, 'E'
				jmp return_event
			cmp5:
			cmp ah, F_SC
			jne end_readkey
				mov al, 'F'
				jmp return_event
			end_cmp:

			Invoke GotoClamp, 0, 19, 0, 38

			; Save the position
			; Write the numbers
			; Then Return to the Position
			push edx
			mov eax, 0
			mov bl, dh
			mov al, dl

			mov dh, 1
			mov dl, 50
			call GotoXY

			call WriteDec
			mov al, ' '
			call WriteChar
			mov al, bl
			call WriteDec
			mov al, ' '
			call WriteChar
			pop edx
			call GotoXY

		end_readkey:

		; Small delay makes it faster
		mov eax, 10 ; 1000 is one second
		call Delay

	jmp KeyboardInput

	return_event:
	pop ebx

	RET
KeyTest ENDP

END