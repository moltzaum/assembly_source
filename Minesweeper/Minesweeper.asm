
Include Irvine32.inc
Include inc_file.inc

.data
; I started off with just a 9x9 grid.
; The grid seems to scale well when rows == cols
; when cols > rows bomb density rises
; when rows > cols the display data behaves strangely
rows = 16
cols = 16
display_data BYTE rows Dup(cols Dup('*'))
internal_data BYTE rows Dup(cols Dup(0))
game_over BYTE "Game Over!", 0ah, 0dh, 0

two BYTE 2 ; div

; TODO test if the game is won!

.code
main PROC
	
	call Randomize
	Invoke GenerateBombs, ADDR internal_data, rows, cols
	Invoke SetBombNeighbors, ADDR internal_data, rows, cols
	Invoke PrintData, ADDR display_data, rows, cols
	;Invoke GotoPrint, ADDR display_data, rows, cols

	; Set starting position
	mov dh, 10
	mov dl, 10
	call GotoXY

	L1:
		; Handles Arrow Keys
		; Returns when an event is triggered
		Invoke KeyTest

		push edx ; save pos
		; al 'F' or 'E'
		; dh x, dl y

		cmp al, 'F' ; TOGGLE FLAG EVENT
		jne cmp2
			; Account for the spaces needed in GotoXY
			mov ah, 0 ; prevent division overflow
			mov al, dl
			div two
			mov dl, al

			Invoke GetData, ADDR display_data, dh, dl, rows
			cmp al, '*'
			jne cmp_F
				Invoke SetData, ADDR display_data, dh, dl, rows, 'F'
			jmp end_toggle
			cmp_F:
			cmp al, 'F'
			jne end_toggle
				Invoke SetData, ADDR display_data, dh, dl, rows, '*'
			end_toggle:

		jmp end_event
		cmp2:
		cmp al, 'E' ; REVEAL EVENT (enter)
		jne err
			
			; Account for the spaces needed in GotoXY
			mov ah, 0 ; prevent division overflow
			mov al, dl
			div two
			mov dl, al

			Invoke GetData, ADDR internal_data, dh, dl, rows
			; FloodFill reveals any space, then continues to fill if it is a space
			Invoke FloodFill, ADDR display_data, ADDR internal_data, rows, cols, dh, dl, 0, 0

			cmp al, '#'
			jne end_event
				; Game over
				mov dh, rows
				mov dl, 0
				call GotoXY
				mov edx, OFFSET game_over
				call WriteString

				Invoke GotoPrint, ADDR display_data, rows, cols
				pop edx

				; Alternatively, have a menu asking to play again.
				; I can potentially have statistics or READ/WRITE saved games
				jmp program_exit

		jmp end_event
		err:
			; should never reach here
		end_event:
			Invoke GotoPrint, ADDR display_data, rows, cols
			pop edx
			call GotoXY
	jmp L1

	program_exit:
	exit
main ENDP
END main

COMMENT &

; GenerateBombs
; SetBombNeighbors
; Gameloop w/ selection
; PrintBoard
;	SetTextForDisp (pass disp into al, change the text color)

; Board
;	is a partially filled BYTE array w/ a max size
;	will need to maintain a row and col variable
; Board Data:
; CHAR display (default *, can change to F only if it is *)
; CHAR data (can be: ' ', 1-8, or '#';	on click: mov display, data)

; Around 12% (10 in 81) spots should be bombs (div 8 should be good)
1 2 * * * * * * *
  1 2 * * * * # *
    1 1 1 1 * * *
          1 2 * *
            2 * *
            1 * *
1 2 2 2 1   1 1 1
* * * * 1 * * * *
* * * * * * * * *

&