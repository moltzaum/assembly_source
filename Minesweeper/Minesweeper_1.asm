
Include Irvine32.inc

.code

PrintWithGoto PROC,
	rows:BYTE,
	cols:BYTE
	
	push edx
	push eax

	mov dx, 0
	movzx ecx, rows
	L1:
		push ecx
		movzx ecx, cols
		L2:
			call GotoXY
			mov al, '*'
			call WriteChar
			mov al, ' '
			add dl, 2
		loop L2
		pop ecx
		mov dl, 0
		inc dh
	loop L1

	pop eax
	pop edx

	RET
PrintWithGoto ENDP

;---------------------------------------------------------------
; Color Test
; Description:
;	Colors are printed in the order: black, blue, green, cyan,
;	red, magenta, brown, lightGray, gray, lightBlue, lightGreen,
;	lightCyan, lightRed, lightMagenta, yellow, white.
;---------------------------------------------------------------
ColorTest PROC
	
	.data
	msg BYTE "Color Test", 0ah, 0dh, 0

	.code
	push eax
	push ecx
	push edx

	call GetTextColor
	push eax

	mov edx, OFFSET msg
	mov eax, 0
	mov ecx, 16 ; 255 for backgrounds
	L1:
		call SetTextColor
		call WriteString
		inc eax
	loop L1

	pop eax
	call SetTextColor

	pop edx
	pop ecx
	pop eax

	RET
ColorTest ENDP

BoardTestPrint PROC
	.data
	b1 BYTE "1 2 * * * * * * *", 0ah, 0dh,
			"  1 2 * * * * # *", 0ah, 0dh,
			"    1 1 1 1 * * *", 0ah, 0dh,
			"          1 2 * *", 0ah, 0dh,
			"            2 * *", 0ah, 0dh,
			"            1 * *", 0ah, 0dh,
			"1 2 2 2 1   1 1 1", 0ah, 0dh,
			"* * * * 1 * * * *", 0ah, 0dh, 0
	.code
	mov edx, OFFSET b1
	call WriteString
	RET
BoardTestPrint ENDP

main proc
	
	;Invoke PrintWithGoto, 29, 60
	;Invoke ColorTest
	Invoke BoardTestPrint

	exit
main endp
end main

COMMENT &

Minesweeper:

; Basic:
; Board
;	is a partially filled BYTE array w/ a max size
;	will need to maintain a row and col variable
; Board Data:
;	bomb vs. non bomb (0 or 1)
;	flagged vs. not flagged (0 or 1)
;	display vs. don't display (0 or 1)		Like displaying * or F VS. ' ', 1-8, or # ?
;	surrounding bomb# (max 8, 1000b)
; We could maybe have a parallel BYTE array for the display?
; OR
; CHAR to display
; w/ display (OR we could use GotoXY to overwrite the current pos wo/ needing to keep individual display information)
; and Flagged
; OR
; CHAR display (default *, can change to F only if it is *)
; CHAR data (can be: ' ', 1-8, or '#';	on click: mov display, data)

; Around 12% (10 in 81) spots should be bombs
1 2 * * * * * * *
  1 2 * * * * # *
    1 1 1 1 * * *
          1 2 * *
            2 * *
            1 * *
1 2 2 2 1   1 1 1
* * * * 1 * * * *
* * * * * * * * *

; Generate random number of bombs

; Advanced:
; Save Game
; Load Game

; Colors:
; Red:		8-5
; Yellow:	4-3
; Green:	2-1
; Blue: bombs *,	Red:	Flag 

; Backgrounds
; black, yellow, or white on red for game over?
; white background for selection, depending on
; if it is needed

&