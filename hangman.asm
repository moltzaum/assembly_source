; Matthew Moltzau
; Assembly - Test2

Include Irvine32.inc

.code
main PROC

.data
welcome BYTE "----------------------------------------------------------", 0ah, 0dh,
			 " Welcome to Hangman!",									   0ah, 0dh,
			 " Once we start the game, you have 10 letter guesses total",  0ah, 0dh,
			 " and 3 word guesses. Each guess, regardless of whether it",  0ah, 0dh,
			 " is correct or not will decrement from your count.",		   0ah, 0dh,
			 "----------------------------------------------------------", 0ah, 0dh, 0

menu BYTE "[0]: Start Game", 0ah, 0dh,
		  "[1]: Quit", 0ah, 0dh,
		  ">> ", 0

error BYTE "Only 0 and 1 are valid options.", 0ah, 0dh, 0

letter_guesses BYTE 10
word_guesses BYTE 3

; Did not get to these:
lguess_total DWORD 0
wguess_total DWORD 0
games_won WORD 0
games_lost WORD 0

.code
	call Randomize	; seed the random number generator

	; Clear Registers
	mov eax, 0
	mov ebx, 0
	mov ecx, 0
	mov edx, 0
	mov esi, 0

	; WELCOME MESSAGE
	mov edx, OFFSET welcome
	call WriteString
	call WaitMsg
	call Crlf

	MenuLoop:
		; DISPLAY MENU
		; [0]: Play (this also gets triggered if the user enters nothing)
		; [1]: Quit
		mov edx, OFFSET menu
		call WriteString
		call ReadDec ; reads into eax
		call Crlf

		; CMP MENU OPTIONS
		cmp eax, 1
		je menu_exit
		cmp eax, 0
		je cont_menu
			mov edx, OFFSET error
			call WriteString
			jmp MenuLoop
		cont_menu:
		
		; SETUP GAME
		call GetRndWord			; OFFSET into EDX, length into al
		movzx ecx, al			; word length
		mov ah, letter_guesses	; letter guesses into ah
		mov al, word_guesses	; word guesses into al
		call PlayGame

	jmp MenuLoop ; loopnz loopz
	menu_exit:
exit
main ENDP

;---------------------------------------------
; GetRndWord
; Precondition: Random seed must be set
; Returns: word OFFSET into EDX, LENGTH into al
;---------------------------------------------
GetRndWord PROC
.data
	word0 BYTE "kiwi", 0h
	word1 BYTE "canoe", 0h
	word2 BYTE "doberman", 0h
	word3 BYTE "frame", 0h
	word4 BYTE "bannana", 0h
	word5 BYTE "orange", 0h
	word6 BYTE "frigate", 0h
	word7 BYTE "ketchup", 0h
	word8 BYTE "postal", 0h
	word9 BYTE "basket", 0h
	word10 BYTE "cabinent", 0h
	word11 BYTE "birch", 0h
	word12 BYTE "machine", 0h
	word13 BYTE "mississipian", 0h
	word14 BYTE "destroyer", 0h
	word15 BYTE "tank", 0h
	word16 BYTE "fruit", 0h
	word17 BYTE "nibble", 0h
	word18 BYTE "assembly", 0h
	word19 BYTE "offensive", 0h
.code
	
	call Random32	; random large num into EAX
	mov ah, 0		; prevent overflow error
	mov bl, 20		; divisor
	div bl ; AX % BL --> AH = Remainder
	
	cmp ah, 0
	jne check1
		mov edx, OFFSET word0
		mov ax, LENGTHOF word0
		jmp end_case
	check1:
	cmp ah, 1
	jne check2
		mov edx, OFFSET word1
		mov ax, LENGTHOF word1
		jmp end_case
	check2:
	cmp ah, 2
	jne check3
		mov edx, OFFSET word2
		mov ax, LENGTHOF word2
		jmp end_case
	check3:
	cmp ah, 3
	jne check4
		mov edx, OFFSET word3
		mov ax, LENGTHOF word3
		jmp end_case
	check4:
	cmp ah, 4
	jne check5
		mov edx, OFFSET word4
		mov ax, LENGTHOF word4
		jmp end_case
	check5:
	cmp ah, 5
	jne check6
		mov edx, OFFSET word5
		mov ax, LENGTHOF word5
		jmp end_case
	check6:
	cmp ah, 6
	jne check7
		mov edx, OFFSET word6
		mov ax, LENGTHOF word6
		jmp end_case
	check7:
	cmp ah, 7
	jne check8
		mov edx, OFFSET word7
		mov ax, LENGTHOF word7
		jmp end_case
	check8:
	cmp ah, 8
	jne check9
		mov edx, OFFSET word8
		mov ax, LENGTHOF word8
		jmp end_case
	check9:
	cmp ah, 9
	jne check10
		mov edx, OFFSET word9
		mov ax, LENGTHOF word9
		jmp end_case
	check10:
	cmp ah, 10
	jne check11
		mov edx, OFFSET word10
		mov ax, LENGTHOF word10
		jmp end_case
	check11:
	cmp ah, 11
	jne check12
		mov edx, OFFSET word11
		mov ax, LENGTHOF word11
		jmp end_case
	check12:
	cmp ah, 12
	jne check13
		mov edx, OFFSET word12
		mov ax, LENGTHOF word12
		jmp end_case
	check13:
	cmp ah, 13
	jne check14
		mov edx, OFFSET word13
		mov ax, LENGTHOF word13
		jmp end_case
	check14:
	cmp ah, 14
	jne check15
		mov edx, OFFSET word14
		mov ax, LENGTHOF word14
		jmp end_case
	check15:
	cmp ah, 15
	jne check16
		mov edx, OFFSET word15
		mov ax, LENGTHOF word15
		jmp end_case
	check16:
	cmp ah, 16
	jne check17
		mov edx, OFFSET word16
		mov ax, LENGTHOF word16
		jmp end_case
	check17:
	cmp ah, 17
	jne check18
		mov edx, OFFSET word17
		mov ax, LENGTHOF word17
		jmp end_case
	check18:
	cmp ah, 18
	jne check19
		mov edx, OFFSET word18
		mov ax, LENGTHOF word18
		jmp end_case
	check19:
	cmp ah, 19
		mov edx, OFFSET word19
		mov ax, LENGTHOF word19
	end_case:
	RET
GetRndWord ENDP

;------------------------------------------------------
; Display Word
; Recieves:
;	ebx as a mask to show certain characters
;	edx word OFFSET
;	ecx word length
; Displays:
;	Word = _ _ _ _ _
;	OR
;	Word = _ e _ _ o
;------------------------------------------------------
DisplayWord PROC
.data
	disp BYTE "Word =", 0
.code
	push ecx
	push ebx
	push eax
	push edx

	push edx ; Word =
	mov edx, OFFSET disp
	call WriteString
	pop edx
	
	ror ebx, cl ; rotate all bits off right
	dec ecx
	PrintLoop:
		
		mov eax, ' '
		call WriteChar

		rol ebx, 1 ; get next bit
		TEST ebx, 1 ; non-destructive AND: is the bit set?
		jnz print_char
			mov al, '_'
			call WriteChar
		jmp print_end
		print_char:
			mov al, BYTE PTR [edx]
			call WriteChar
		print_end:
		inc edx

	loop PrintLoop
	call Crlf

	pop edx
	pop eax
	pop ebx
	pop ecx
	RET
DisplayWord ENDP

;------------------------------------------------------------
; Compare Strings
; Recieves:
;	ESI as word OFFSET
;	EDX as guess OFFSET
; Returns:
;	Sets the zero flag if the strings don't match
;	Clears the zero flag if the string do match
;	So: if 0, match is FALSE; if 1, match is TRUE
;------------------------------------------------------------
CmpStrings PROC
	push esi
	push edx
	push eax

	cmp_loop:
		movzx eax, BYTE PTR [esi]
		cmp al, [edx]
		jne word_false   ; [esi] != [edx], word mismatch
		cmp al, 0     ; null terminator where [esi] == [edx]
		je word_true
		inc esi
		inc edx
	jmp cmp_loop

	word_false:
		AND dl, 0  ; sets the zero flag
	jmp cmp_end
	word_true:
		OR dl, 1   ; clear the zero flag
	cmp_end:

	pop eax
	pop edx
	pop esi
	RET
CmpStrings ENDP

;----------------------------------------------
; Letter Guess
; Recieves:
;	ESI as word OFFSET
;	dl as char to scan for
; Returns:
;	EBX as mask for dl
; Example:
;	edx -> bannana
;	dl = a
;	ebx is now 0100101
;----------------------------------------------
LetterGuess PROC
	push esi
	push edx

	mov ebx, 0
	lguess_loop:
		mov dh, BYTE PTR [esi]
		cmp dl, dh
		jne check_termination
			OR ebx, 1 ; just add a bit
		check_termination:
		cmp dh, 0 ; null termination
		je lguess_end
		
		inc esi
		shl ebx, 1 ; bannana:a -> 0100101
	jmp lguess_loop
	lguess_end:

	pop edx
	pop esi
	RET
LetterGuess ENDP

;------------------------------------------
; To Lowercase
; Recieves:
;	EDX as string OFFSET
; Returns:
;	unchanged offset with a changed string
;	that is now lowercase
;------------------------------------------
ToLower PROC
	push edx
	push eax

	lower_loop:
		cmp BYTE PTR [edx], 0 ; null termation
		je exit_lwr

		mov al, BYTE PTR [edx]  	; get char
		cmp al, 'A' 				; if al < 'A'
		jb NotUpperCase				;	continue to bottom
		cmp al, 'Z' 				; if al > 'Z'
		ja NotUpperCase				;	continue to bottom
			add al, 20h ; 'A' 41, 'a' 61
			mov BYTE PTR [edx], al  ; set char
		NotUpperCase:
		inc edx ; continue to next char
	jmp lower_loop
	exit_lwr:

	pop eax
	pop edx
	RET
ToLower ENDP

;----------------------------------------
; Play Game
; Recieves:
;	EDX as word OFFSET
;	ECX as word LENGTH
;	AH as letter guesses
;	AL as word guesses
; Returns:
;	AH remaining letter guesses
;	AL remaining word guesses
;	TODO set zero flag if game was lostcu 
;----------------------------------------
PlayGame PROC
.data
	prompt BYTE "Guess either a letter or a word.", 0ah, 0dh, ">> ", 0
	lguesses BYTE " letter guesses remaining", 0ah, 0dh, 0
	wguesses BYTE " word guesses remaining", 0ah, 0dh, 0
	wrongw BYTE "The word you guessed was incorrect.", 0ah, 0dh, 0
	win BYTE "You've won the game. Congratulations!", 0ah, 0dh, 0
	loss BYTE "You didn't win the game. Better luck next time.", 0ah, 0dh, 0
	err1 BYTE "You cannot enter any more letters.", 0ah, 0dh, 0
	err2 BYTE "You cannot enter any more words.", 0ah, 0dh, 0
	err3 BYTE "You must enter something!", 0ah, 0dh, 0
	guess BYTE 32 DUP(0)
	b_letters DWORD 0
	letter_guesses2 BYTE 0
	word_guesses2 BYTE 0
.code
	push edx
	push ecx
	push esi

	; DISPLAY THE STRING (for debug)
	; call WriteString
	; call Crlf

	mov letter_guesses2, ah
	mov word_guesses2, al

	; Setup Letter Flags (ebx and b_letters)
	mov ebx, 0
	NOT ebx ; FFFFFFFFh
	mov b_letters, 0 ; reset var
	shld b_letters, ebx, cl ; if cl = 6 then 0000003Fh
	sub b_letters, 1
	NOT ebx ; want at 0

	mov esi, edx ; will need edx for other stuff
	
	PlayLoop:
		
		; WRITE REMAINING GUESSES
		movzx eax, letter_guesses2
		call WriteDec
		mov edx, OFFSET lguesses
		call WriteString
		movzx eax, word_guesses2
		call WriteDec
		mov edx, OFFSET wguesses
		call WriteString

		mov edx, esi
		call DisplayWord

		; GET USER INPUT
		mov edx, OFFSET prompt
		call WriteString
		mov edx, OFFSET guess
		push ecx
		mov ecx, LENGTHOF guess
		call ReadString ; OFFSET into EDX, len into EAX
		call ToLower    ; converts string to lowercase
		pop ecx

		cmp al, 0 ; Did the user actually input anything?
		jne test_if_1
			mov edx, OFFSET err3
			call WriteString
			jmp PlayLoop
		test_if_1:
		cmp al, 1 ; is input a letter or a word?
		jne word_input
			; WE HAVE A LETTER INPUT

			cmp letter_guesses2, 0 ; Do we have any more letter guesses left?
			jne remaining_letters
				; cannot enter any more letters
				mov edx, OFFSET err1
				call WriteString
				jmp PlayLoop ; continue
			remaining_letters:

			mov dl, BYTE PTR [edx] ; overwrite self with the input
			push ebx		 ; save ebx
			call LetterGuess ; returns EBX
			pop edx			 ; restore into edx
			OR ebx, edx		 ; combine

			cmp ebx, b_letters
			jne not_win
				jmp VICTORY
			not_win:
			
			cmp letter_guesses2, 0
			je keepzero1
				dec letter_guesses2 ; decrement letter guesses
			keepzero1:

		jmp cont_game
		word_input:
			; WE HAVE A WORD INPUT

			cmp word_guesses2, 0 ; Do we have any more word guesses left?
			jne remaining_words
				; cannot enter any more words
				mov edx, OFFSET err2
				call WriteString
				jmp PlayLoop ; continue
			remaining_words:

			call CmpStrings ; compares edx and esi
			jz mismatch
				jmp VICTORY
			mismatch:
				cmp word_guesses2, 0
				je keepzero2
					dec word_guesses2 ; decrement word guesses
				keepzero2:
				mov edx, OFFSET wrongw
				call WriteString

		jmp cont_game
		victory:
			mov ebx, b_letters ; set flags to display word
			mov edx, esi
			call DisplayWord
			mov edx, OFFSET win
			call WriteString
			jmp exit_game
		cont_game:
		
		cmp word_guesses2, 0 ; Do I have 0 word guesses and 0 letter guesses?
		jne can_guess
		cmp letter_guesses2, 0
		je lost_game
		can_guess:
	jmp PlayLoop
	lost_game:
	mov edx, OFFSET loss
	call WriteString

	exit_game:
	; prepare output
	mov ah, letter_guesses2
	mov al, word_guesses2

	pop esi
	pop ecx
	pop edx
	RET
PlayGame ENDP

end main