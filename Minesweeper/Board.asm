
Include Irvine32.inc
Include inc_file.inc

.code

; Chapter 9.4 discusses some row-col operations
; returns to esi
CoordToOffset PROC,
	row:BYTE,
	col:BYTE,
	row_size:BYTE

	push eax

	mov esi, 0
	movzx eax, row
	mul row_size
	add esi, eax

	movzx eax, col
	add esi, eax

	pop eax

	RET
CoordToOffset ENDP

; Just pass internal data array
; Randomzie should be called beforehand
GenerateBombs PROC,
	data_arr:DWORD,
	rows:BYTE,
	cols:BYTE
	LOCAL eight:BYTE
	mov eight, 8

	push eax ; div, mul, RandomRange
	push edx ; main data offset
	push ecx ; loop counter
	push esi ; index value

	; Get # of bombs to place (simple ratio)
	movzx eax, rows
	mul cols  ; product into ax
	div eight ; result into al

	mov edx, data_arr
	movzx ecx, al
	L1:
		; Chapter 9.4 discusses some row-col operations
		mov esi, 0
		movzx eax, rows
		call RandomRange
		mul rows
		add esi, eax

		movzx eax, cols
		call RandomRange
		add esi, eax

		cmp BYTE PTR [edx + esi], '#'
		jne set_bomb
			jmp L1 ; redo if collision
		set_bomb:
		mov BYTE PTR [edx + esi], '#'
	loop L1

	pop esi
	pop ecx
	pop edx
	pop eax

	RET
GenerateBombs ENDP

; returns into al
GetData PROC,
	data_arr:DWORD,
	row:BYTE,
	col:BYTE,
	row_size:BYTE

	push edx

	mov edx, data_arr
	mov bh, row
	mov bl, col
	Invoke CoordToOffset, bh, bl, row_size
	mov al, BYTE PTR [edx + esi]

	pop edx

	RET
GetData ENDP

SetData PROC,
	data_arr:DWORD,
	row:BYTE,
	col:BYTE,
	row_size:BYTE,
	data_:BYTE

	mov edx, data_arr
	Invoke CoordToOffset, row, col, row_size
	mov al, data_
	mov BYTE PTR [edx + esi], al

	RET
SetData ENDP

; clamp function for bytes
; pass variable by reference
; returns true if clamp was performed

; it is assumed that min < max, but the
; function will still work for the most part.
; if n < min we clamp to min, even if max is less than min
; and if n > min && n > max, we clamp to max
Clamp PROC,
	numRef:DWORD,
	min:SBYTE,
	max:SBYTE

	push eax
	push edx
	mov bl, 0
	mov edx, numRef

	mov al, min
	cmp [edx], al
	jnl test_max ; clamp to min
		mov [edx], al
		mov bl, 1
	jmp good
	test_max:
	mov ah, max
	cmp [edx], ah
	jnge good ; clamp to max
		mov [edx], ah
		mov bl, 1
	good:

	pop edx
	pop eax

	RET
Clamp ENDP

ClampXY PROC,
	xRef:DWORD,
	yRef:DWORD,
	minX:SBYTE,
	maxX:SBYTE,
	minY:SBYTE,
	maxY:SBYTE

	Invoke Clamp, xRef, minX, maxX
	mov bh, bl
	Invoke Clamp, yRef, minY, maxY
	OR bl, bh

	RET
ClampXY ENDP

; increments bombCount if there is a bomb
; located at x+x_offset, y+y_offset
ProbeForBomb PROC,
	data_arr:DWORD,
	rows:BYTE,
	cols:BYTE,
	bombCount:DWORD,
	x:BYTE,
	y:BYTE,
	x_offset:SBYTE,
	y_offset:SBYTE

	push ebx

	mov bl, x_offset
	add x, bl
	mov bl, y_offset
	add y, bl
	
	Invoke ClampXY, ADDR x, ADDR y, 0, rows, 0, cols
	cmp bl, 1  ; Was the clamp preformed?
	je no_bomb ; if yes, coord is out of bounds
		Invoke GetData, data_arr, x, y, rows
		cmp al, '#'
		jne no_bomb
			;add [bombCount], 1
			;inc BYTE PTR [bombCount]
			mov ebx, bombCount
			inc BYTE PTR [ebx]
	no_bomb:

	pop ebx

	RET
ProbeForBomb ENDP

SetBombNeighbors PROC,
	data_arr:DWORD,
	rows:BYTE,
	cols:BYTE
	LOCAL bombCount:BYTE, x:BYTE, y:BYTE
	mov bombCount, 0
	
	mov x, 0
	movzx ecx, rows
	L1:
		mov y, 0
		push ecx
		movzx ecx, cols
		L2:
			Invoke GetData, data_arr, x, y, rows
			cmp al, '#'
			je cont
		
			; 0 1 2		0,0		0,1		0,2
			; 3 4 5		1,0		1,1		1,2
			; 6 7 8		2,0		2,1		2,2
			mov edx, data_arr
			mov bombCount, 0
			Invoke ProbeForBomb, edx, rows, cols, ADDR bombCount, x, y, -1, -1 ; 0 upper left
			Invoke ProbeForBomb, edx, rows, cols, ADDR bombCount, x, y, -1,  0 ; 1 up
			Invoke ProbeForBomb, edx, rows, cols, ADDR bombCount, x, y, -1,  1 ; 2 upper right
			Invoke ProbeForBomb, edx, rows, cols, ADDR bombCount, x, y,  0, -1 ; 3 left
			Invoke ProbeForBomb, edx, rows, cols, ADDR bombCount, x, y,  0,  1 ; 5 right
			Invoke ProbeForBomb, edx, rows, cols, ADDR bombCount, x, y,  1, -1 ; 6 down left
			Invoke ProbeForBomb, edx, rows, cols, ADDR bombCount, x, y,  1,  0 ; 7 down
			Invoke ProbeForBomb, edx, rows, cols, ADDR bombCount, x, y,  1,  1 ; 8 down right
			;Invoke ProbeForBomb, ADDR data_arr, rows, cols, ADDR bombCount, x, y,  1,  1 ; 8 down right

			cmp bombCount, 0
			je set_blank
				add bombCount, '0'
				; this changes bombCount
				Invoke SetData, data_arr, x, y, rows, bombCount
			jmp cont
			set_blank:
				Invoke SetData, data_arr, x, y, rows, ' '
			cont:
			inc y

		; LOOP L2 (jump is too far for some reason, so do jne)
		dec ecx
		jne L2

		pop ecx
		inc x

	; LOOP L1 (jump is too far for some reason, so do jne)
	dec ecx
	jne L1

	RET
SetBombNeighbors ENDP

SetColorForData PROC,
	data_:BYTE

	push eax

	cmp data_, '*'
	jne cmp2
		mov eax, white
		call SetTextColor
	jmp end_cmp
	cmp2:
	cmp data_, 'F'
	jne cmp3
		mov eax, red
		call SetTextColor
	jmp end_cmp
	cmp3:
	cmp data_, '#'
	jne cmp4
		mov eax, red
		call SetTextColor
	jmp end_cmp
	cmp4:
	cmp data_, '1'
	jne cmp5
		mov eax, blue
		call SetTextColor
	jmp end_cmp
	cmp5:
	cmp data_, '2'
	jne cmp6
		mov eax, green
		call SetTextColor
	jmp end_cmp
	cmp6:
	cmp data_, '3' ; >=
	jb end_cmp
	cmp data_, '8' ; <=
	ja end_cmp
		mov eax, red
		call SetTextColor
	end_cmp:

	pop eax

	RET
SetColorForData ENDP

; [DEPRECATED] GotoPrint works better with my control interface
PrintData PROC,
	data_arr:DWORD,
	rows:BYTE,
	cols:BYTE
	LOCAL x:BYTE, y:BYTE

	call GetTextColor
	push eax

	mov x, 0
	movzx ecx, rows
	L1:
		mov y, 0
		push ecx
		movzx ecx, cols
		L2:
			Invoke GetData, data_arr, x, y, rows
			Invoke SetColorForData, al
			call WriteChar
			mov al, ' '
			call WriteChar
			inc y
		loop L2
		pop ecx
		call Crlf
		inc x
	loop L1
	call Crlf

	pop eax
	call SetTextColor

	RET
PrintData ENDP

GotoPrint PROC,
	data_arr:DWORD,
	rows:BYTE,
	cols:BYTE
	LOCAL two:BYTE, x:BYTE, y:BYTE
	mov two, 2

	call GetTextColor
	push eax

	mov x, 0
	movzx ecx, rows
	L1:
		mov y, 0
		push ecx
		movzx ecx, cols
		L2:
			
			mov dh, x

			mov al, y
			mul two
			mov dl, al
			call GotoXY

			Invoke GetData, data_arr, x, y, rows
			Invoke SetColorForData, al
			call WriteChar
			inc y
		loop L2
		pop ecx
		call Crlf
		inc x
	loop L1
	call Crlf

	pop eax
	call SetTextColor

	RET
GotoPrint ENDP

FloodFill PROC,
	disp_arr:DWORD,
	data_arr:DWORD,
	rows:BYTE,
	cols:BYTE,
	x:BYTE,
	y:BYTE,
	x_offset:SBYTE,
	y_offset:SBYTE

	; Apply offset immediately
	mov ah, x_offset
	mov al, y_offset
	add x, ah
	add y, al

	Invoke ClampXY, ADDR x, ADDR y, 0, rows, 0, cols
	cmp bl, 1  ; Stop if THIS is out of bounds
	je stop_continuation
	; reveal

	Invoke GetData, data_arr, x, y, rows
	mov ah, al
	Invoke GetData, disp_arr, x, y, rows
	cmp ah, al ; Stop if THIS is already displayed
	je stop_continuation

	Invoke SetData, disp_arr, x, y, rows, ah
	cmp ah, ' ' ; Stop if THIS is not a space
	jne stop_continuation

		; Invoke for up, left, down, right
		Invoke FloodFill, disp_arr, data_arr, rows, cols, x, y,  1,  0
		Invoke FloodFill, disp_arr, data_arr, rows, cols, x, y, -1,  0
		Invoke FloodFill, disp_arr, data_arr, rows, cols, x, y,  0, -1
		Invoke FloodFill, disp_arr, data_arr, rows, cols, x, y,  0,  1

		; Invoke for corners
		Invoke FloodFill, disp_arr, data_arr, rows, cols, x, y,  -1,  -1
		Invoke FloodFill, disp_arr, data_arr, rows, cols, x, y,  -1,  1
		Invoke FloodFill, disp_arr, data_arr, rows, cols, x, y,  1,  -1
		Invoke FloodFill, disp_arr, data_arr, rows, cols, x, y,  1,  1
	not_fillable:
	stop_continuation:

	RET
FloodFill ENDP

END