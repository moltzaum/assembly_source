; Matthew Moltzau
; Assembly - PA6

Include Irvine32.inc

.data
MAX_LENGTH = 32
phrase BYTE MAX_LENGTH Dup(0)
phrase_len BYTE 0
key BYTE MAX_LENGTH Dup(0)

welcomeMsg BYTE "Welcome to the encryption/decryption program.", 0ah, 0dh,
				"Begin by entering a phrase, then a key to match the phrase.", 0ah, 0dh,
				"Warning: If you re-enter a phrase, the key will be reset!", 0ah, 0dh, 0

menuPrompt BYTE "----------------------", 0ah, 0dh,
				"[1]: Enter a phrase   ", 0ah, 0dh,
				"[2]: Enter a key      ", 0ah, 0dh,
				"[3]: Encrypt phrase   ", 0ah, 0dh,
				"[4]: Decrypt phrase   ", 0ah, 0dh,
				"[5]: Print phrase     ", 0ah, 0dh,
				"[6]: Print key        ", 0ah, 0dh,
				"[7]: Exit program	   ", 0ah, 0dh,
				"----------------------", 0ah, 0dh, 0
				
wordPrompt BYTE "Please enter a word or phrase.", 0ah, 0dh, ">> ", 0
		 
result1 BYTE "The phrase is: ", 0
result2 BYTE "The key is: ", 0
.code
main PROC
	
	mov eax, 0

	mov edx, OFFSET welcomeMsg
	call WriteString
	
	Menu:
	mov edx, OFFSET menuPrompt
	call WriteString ; display prompt
	call ReadDec 	 ; unsigned int input
	
	;---------------------------
	; [1]: ENTER A PHRASE
	cmp al, 1
	jne m2
		; Get user input and edit
		mov edx, OFFSET wordPrompt
		call WriteString
		mov ecx, MAX_LENGTH
		mov edx, OFFSET phrase
		call ReadString
		movzx ecx, al              ; concrete string length
		mov ebx, OFFSET phrase_len ; var passed as reference
		call RemoveNonLetters ; updates the length of the string
		
		; Perform operations with updated length
		; I clear the string here because the key
		; length is dependant on the phrase.
		movzx ecx, phrase_len
		call ToUpper
		mov edx, OFFSET key
		call ClearString
		
		; Display
		mov edx, OFFSET result1
		call WriteString
		mov edx, OFFSET phrase
		call PrintPhrase ; uses ecx
		
	jmp Menu ; back to top
	
	;---------------------------
	m2: ; [2]: ENTER A KEY
	cmp al, 2
	jne m3
		; MAKE SURE A PHRASE HAS BEEN ENTERED FIRST
		cmp phrase_len, 0
		jne input_key
			.data
			err1 BYTE "Before inputting the key you must input the phrase.", 0ah, 0dh, 0
			.code
			mov edx, OFFSET err1
			call WriteString
			jmp Menu ; back to top
		input_key:
		
		; Get user input and edit
		mov edx, OFFSET wordPrompt
		call WriteString
		mov ecx, MAX_LENGTH
		mov edx, OFFSET key
		call ReadString
		movzx ecx, al ; string length
		
		call TrimWhitespace ; (changes ecx)
		call ToUpper
		mov esi, OFFSET phrase
		
		mov eax, ecx ; key length
		movzx ecx, phrase_len
		call MatchKeyToPhrase ; makes the lengths match
		
		; Display
		mov edx, OFFSET result2
		call WriteString
		mov edx, OFFSET key
		call PrintPhrase ; uses ecx
		
	jmp Menu ; back to top
	
	;---------------------------	
	m3: ; [3]: ENCRYPT PHRASE
	cmp al, 3
	jne m4
		; Can't call if phrase_len == 0 or [key] == 0
		cmp phrase_len, 0
		je fail_encrypt1
		cmp [key], 0
		je fail_encrypt2
			mov esi, OFFSET phrase
			mov edx, OFFSET key
			call Encrypt
		jmp Menu ; back to top
		
		fail_encrypt1:
		.data
		err2_1 BYTE "Can't encrypt because the phrase isn't set.", 0ah, 0dh, 0
		.code
		mov edx, OFFSET err2_1
		call WriteString
		jmp Menu ; back to top
		
		fail_encrypt2:
		.data
		err2_2 BYTE "Can't encrypt because the key isn't set.", 0ah, 0dh, 0
		.code
		mov edx, OFFSET err2_2
		call WriteString
		jmp Menu ; back to top
	
	;---------------------------
	m4: ; [4]: DECRYPT PHRASE
	cmp al, 4
	jne m5
		; Can't call if phrase_len == 0 or [key] == 0
		cmp phrase_len, 0
		je fail_decrypt1
		cmp [key], 0
		je fail_decrypt2
			mov esi, OFFSET phrase
			mov edx, OFFSET key
			call Decrypt
		jmp Menu ; back to top
		
		fail_decrypt1:
		.data
		err3_1 BYTE "Can't decrypt because the phrase isn't set.", 0ah, 0dh, 0
		.code
		mov edx, OFFSET err3_1
		call WriteString
		jmp Menu ; back to top
		
		fail_decrypt2:
		.data
		err3_2 BYTE "Can't decrypt because the key isn't set.", 0ah, 0dh, 0
		.code
		mov edx, OFFSET err3_2
		call WriteString
		jmp Menu ; back to top
		
	;---------------------------
	m5: ; [5]: PRINT PHRASE
	cmp al, 5
	jne m6
		
		cmp phrase_len, 0
		jne ok_to_print1
		
			;---------------------------
			; Can't print if empty
			.data
			err4 BYTE "You need to enter a phrase before you print it.", 0ah, 0dh, 0
			.code
			mov edx, OFFSET err4
			call WriteString
			jmp Menu
		
		ok_to_print1:
		movzx ecx, phrase_len
		mov edx, OFFSET phrase
		call PrintPhrase
	jmp Menu ; back to top
	
	;---------------------------
	m6: ; [6]: PRINT KEY
	cmp al, 6
	jne m7
		
		cmp [key], 0
		jne ok_to_print2
			
			;---------------------------
			; Can't print if empty
			.data
			err5 BYTE "You need to enter a key before you print it.", 0ah, 0dh, 0
			.code
			mov edx, OFFSET err5
			call WriteString
			jmp Menu
			
		ok_to_print2:
		movzx ecx, phrase_len
		mov edx, OFFSET key
		call PrintPhrase
	jmp Menu ; back to top
	
	;---------------------------
	m7: ; [7]: EXIT PROGRAM
	cmp al, 7
	jne m_err
		jmp program_exit
	;---------------------------
	m_err: ; INVALID OPTION
		.data
		err_m BYTE "Please enter a menu option that fits in the range [1-7].", 0ah, 0dh, 0
		.code
		mov edx, OFFSET err_m
		call WriteString
	jmp Menu
	program_exit:
	exit
main ENDP

;------------------------------------------------------------------
; Match Key to Phrase
; Description: If the key is longer than the phrase, it will be
;	truncated. If it is shorter, then it will be repeated.
; Receives:
;	ESI: OFFSET of phrase
;	EDX: OFFSET of key
;	ECX: phrase length
;	EAX: key length
; Precondition:
;	Neither string should be empty.
; Returns:
;	EAX: updated key length
;------------------------------------------------------------------
MatchKeyToPhrase PROC uses ESI EDX ECX EBX
	cmp ECX, EAX
	ja rep_key  ; if cl > ax
	jb trun_key ; if cl < ax
	je mk_end ; match key end
	
	rep_key:
		mov ebx, edx ; save the original offset
		add edx, eax ; go to end of string (check to see if off by one error here)
		sub ecx, eax ; the number of letters to add is the difference in lengths
		push esi     ; repurposing esi
		mov esi, 0
		MK_loop:
			; adding to the end of the string, the beginning of the string
			mov al, BYTE PTR [ebx + esi]
			mov BYTE PTR [edx + esi], al
			inc esi
		loop MK_loop
		pop esi
		mov eax, ecx ; correct length
	jmp mk_end
	trun_key:
		mov eax, ecx ; set length
		; null terminate at new length
		mov BYTE PTR [edx + eax], 0
		; Warning: Letters after the new
		; length will not be cleared.
	mk_end:
	RET
MatchKeyToPhrase ENDP

;------------------------------------------------------------------
; Encrypt
; Description:
; Receives:
;	ESI: OFFSET of phrase
;	EDX: OFFSET of key
;	ECX: phrase length
; Precondition:
;	It is assumed that the key and phrase have the same length.
;------------------------------------------------------------------
Encrypt PROC uses EDX ESI
	en_loop:
		mov bl, 26				 ; divisor
		sub BYTE PTR [esi], 'A'  ; ASCII to n
		movzx ax, BYTE PTR [edx] ; dividend
		div bl					 ; remainder = AH
		add BYTE PTR [esi], ah   ; shift right
		movzx ax, BYTE PTR [esi] ; dividend
		div bl					 ; remainder = AH
		mov BYTE PTR [esi], ah
		add BYTE PTR [esi], 'A'  ; n to ASCII
		inc esi
		inc edx
	loop en_loop
	
	COMMENT &
	Phrase:
		'R' -> 52 -> 52 - 'A' -> 17 
	Key:
		'A' -> 41 -> 41 % 26 -> 13
	New Phrase:
		17 + 13 -> 30 -> 30 % 26 -> 4 -> 4 + 'A' -> 'E'
	&
	RET
Encrypt ENDP

;------------------------------------------------------------------
; Decrypt
; Description:
; Receives:
;	ESI: OFFSET of phrase
;	EDX: OFFSET of key
;	ECX: phrase length
; Precondition:
;	It is assumed that the key and phrase have the same length.
;------------------------------------------------------------------
Decrypt PROC uses ESI ECX
	de_loop:
		mov bl, 26				 ; divisor
		sub BYTE PTR [esi], 'A'  ; ASCII to n
		movzx ax, BYTE PTR [edx] ; dividend
		div bl					 ; remainder = AH
		sub BYTE PTR [esi], ah   ; shift left (might generate a negative number)
		add BYTE PTR [esi], 26   ; for - n; does not change + n because of mod
		movzx ax, BYTE PTR [esi] ; dividend
		idiv bl					 ; remainder = AH
		mov BYTE PTR [esi], ah
		add BYTE PTR [esi], 'A'  ; n to ASCII
		inc esi
		inc edx
	loop de_loop ; loop de loop!
	RET
Decrypt ENDP

;------------------------------------------------------------------
; Print PHRASE
; Description: Prints the phrase in sub-words of 5 letters each.
;	Example: HELLO WORLD, or THEDO GISCO OL
; Receives:
;	EDX: string OFFSET
;	ECX: string length
; Precondition:
;	For this program is expected that the word is capitalized and
;	has all non-letter characters removed. If this condition is
;	ignored, this procedure will just print what you give it with
;	the same 5 char print spacing rule.
; Returns:
;	Nothing
;------------------------------------------------------------------
PrintPhrase PROC uses EAX EDX ECX
	mov ah, 0 ; count
	PP_loop:
		mov al, BYTE PTR [edx]
		call WriteChar
		
		cmp ah, 4 ; Space every 5 letters printed
		jne PP_cont
			mov al, ' '
			call WriteChar
			mov ah, -1
		PP_cont:
		
		inc ah
		inc edx
		
		mov al, [edx] ; cmp [edx], 0 is wrong?
		cmp al, 0 ; null terminator
	loopnz PP_loop
	call Crlf
	RET
PrintPhrase ENDP

;------------------------------------------------------------------
; To Upper Case
; Description: Converts all lowercase letters to uppercase
; Receives:
;	EDX: string OFFSET
;	ECX: string LENGTH
; Returns: updated string with all uppercase letters
;------------------------------------------------------------------
ToUpper PROC USES EDX ECX
	UC_loop:
		; xxx [a-z] xxx
		cmp BYTE PTR [edx], 'a'
		jb not_lowercase
		cmp BYTE PTR [edx], 'z'
		ja not_lowercase
			sub BYTE PTR [edx], 20h
		not_lowercase:
		inc edx
	loop UC_loop
	RET
ToUpper ENDP

;------------------------------------------------------------------
; ClearString
; Description: Sets all characters of a given string to 0
; Receives:
;	EDX: string OFFSET
;	ECX: string LENGTH
; Returns: string filled with null termination characters
;------------------------------------------------------------------
ClearString PROC USES EDX ECX ESI
	mov esi, 0
	ClearIt:
		mov BYTE PTR [edx + esi], 0
		inc esi
	loop ClearIt
	RET
ClearString ENDP

;------------------------------------------------------------------
; Trim Whitespace
; Description: Removes extraneous spaces (This procedure should
;	pay attention to tabs and newlines to be complete, but I don't
;	need that for this program.)
; Receives:
;	ECX: string LENGTH
;	EDX: string OFFSET
; Returns:
;	ECX: updated string LENGTH
;	EDX: updated string with no spaces
;------------------------------------------------------------------
TrimWhitespace PROC uses EDX ESI EAX
	.data
	tempstr1 BYTE 50 dup(0) ; hold string while working

	.code
	; preserve edx, ecx
	push edx
	push ecx
	
	; clear tempstr for repeated calls from main
	mov edx, offset tempstr1
	mov ecx, 50
	call ClearString
	
	; restore ecx, edx
	pop ecx
	pop edx
	
	push ecx                      ; save value of ecx for next loop
	mov esi, 0                    ; use edi as index to step through the string
	mov edi, 0
	L3_1:
		mov al, byte ptr [edx + esi]  ; grab an element of the string
		
		; check to see if the element is a space. 
		cmp al, ' '
		je skipit_1
			; if determined to be a non-space, then it must be added to the temp string
			mov tempstr1[edi], al
			inc edi         ; move to next element of theString
			inc esi         ; move to next element of temp string
			jmp endloop_1   ; go to the end of the loop
		skipit_1:         	; skipping the element 
			inc esi         ; go to next element of theString
	
		endloop_1:
	loopnz L3_1
	
	pop ecx         ; restores original value of ecx for the next loop
	
	push edi ; save length of the string
	; original line of code: mov [ebx], edi
	
	; copies the temp string to theString will all non-letter elements removed
	mov edi, 0
	L3a_1:
		mov al, tempstr1[edi]
		mov byte ptr [edx + edi], al
		inc edi
	loop L3a_1
	
	pop ecx ; putting the length into ecx
	
	RET
TrimWhitespace ENDP

;------------------------------------------------------------------
; Remove Non-Letters
; Description: Removes all non-letter elements
; Receives:
;	ECX: string LENGTH (convienient as loop counter)
;	EDX: string OFFSET
;	EBX: OFFSET of LENGTH variable (to be updated)
; Returns: string with all non-letter elements removed. Warning:
; 	ECX's length will remain unchanged! Use EBX as the OFFSET of
; 	the changed variable.
;------------------------------------------------------------------
RemoveNonLetters PROC uses ECX EDX ESI
	.data
	tempstr2 BYTE 50 dup(0) ; hold string while working

	.code
	; preserve edx, ecx
	push edx
	push ecx
	
	; clear tempstr for repeated calls from main
	mov edx, offset tempstr2
	mov ecx, 50
	call ClearString
	
	; restore ecx, edx
	pop ecx
	pop edx
	
	push ecx                      ; save value of ecx for next loop
	mov esi, 0                    ; use edi as index to step through the string
	mov edi, 0
	L3_2:
		mov al, byte ptr [edx + esi]  ; grab an element of the string
		
		; check to see if the element is a letter.  
		cmp al, 5Ah
		ja lowercase    ; if above 5Ah has a chance of being lowercase
		cmp al, 41h     ; if below 41h will not be a letter so skip this element
		jb skipit_2
		jmp addit       ; otherwise it is a capital letter and should be added to our temporary string
		
		lowercase:
		cmp al, 61h     
		jb skipit_2     ; if below then is not a letter but is in the range 5Bh and 60h
		cmp al, 7Ah     ; if above then it is not a letter, otherwise it is a lowercase letter
		ja skipit_2
		
		addit:          ; if determined to be a letter, then it must be added to the temp string
			mov tempstr2[edi], al
			inc edi         ; move to next element of theString
			inc esi         ; move to next element of temp string
			jmp endloop_2   ; go to the end of the loop
		skipit_2:             ; skipping the element 
			inc esi         ; go to next element of theString
	
		endloop_2:
	loopnz L3_2
	
	mov [ebx], edi   ; updates length of string
	
	pop ecx         ; restores original value of ecx for the next loop

	; copies the temp string to theString will all non-letter elements removed
	mov edi, 0
	L3a_2:
		mov al, tempstr2[edi]
		mov byte ptr [edx + edi], al
		inc edi
	loop L3a_2

	RET
RemoveNonLetters ENDP

end main

COMMENT &
Welcome to the encryption/decryption program.
Begin by entering a phrase, then a key to match the phrase.
Warning: If you re-enter a phrase, the key will be reset!
----------------------
[1]: Enter a phrase
[2]: Enter a key
[3]: Encrypt phrase
[4]: Decrypt phrase
[5]: Print phrase
[6]: Print key
[7]: Exit program
----------------------
1
Please enter a word or phrase.
>> This is a Ceasar Cipher test
The phrase is: THISI SACEA SARCI PHERT EST
----------------------
[1]: Enter a phrase
[2]: Enter a key
[3]: Encrypt phrase
[4]: Decrypt phrase
[5]: Print phrase
[6]: Print key
[7]: Exit program
----------------------
2
Please enter a word or phrase.
>> Assembly Homework
The key is: ASSEM BLYHO MEWOR KASSE MBL
----------------------
[1]: Enter a phrase
[2]: Enter a key
[3]: Encrypt phrase
[4]: Decrypt phrase
[5]: Print phrase
[6]: Print key
[7]: Exit program
----------------------
3
----------------------
[1]: Enter a phrase
[2]: Enter a key
[3]: Encrypt phrase
[4]: Decrypt phrase
[5]: Print phrase
[6]: Print key
[7]: Exit program
----------------------
5
GMNJH GYNYB RRADM MUJWK DGR
----------------------
[1]: Enter a phrase
[2]: Enter a key
[3]: Encrypt phrase
[4]: Decrypt phrase
[5]: Print phrase
[6]: Print key
[7]: Exit program
----------------------
&

COMMENT &
Welcome to the encryption/decryption program.
Begin by entering a phrase, then a key to match the phrase.
Warning: If you re-enter a phrase, the key will be reset!
----------------------
[1]: Enter a phrase
[2]: Enter a key
[3]: Encrypt phrase
[4]: Decrypt phrase
[5]: Print phrase
[6]: Print key
[7]: Exit program
----------------------
1
Please enter a word or phrase.
>> GMNJH GYNYB RRADM MUJWK DGR
The phrase is: GMNJH GYNYB RRADM MUJWK DGR
----------------------
[1]: Enter a phrase
[2]: Enter a key
[3]: Encrypt phrase
[4]: Decrypt phrase
[5]: Print phrase
[6]: Print key
[7]: Exit program
----------------------
2
Please enter a word or phrase.
>> Assembly Homework
The key is: ASSEM BLYHO MEWOR KASSE MBL
----------------------
[1]: Enter a phrase
[2]: Enter a key
[3]: Encrypt phrase
[4]: Decrypt phrase
[5]: Print phrase
[6]: Print key
[7]: Exit program
----------------------
4
----------------------
[1]: Enter a phrase
[2]: Enter a key
[3]: Encrypt phrase
[4]: Decrypt phrase
[5]: Print phrase
[6]: Print key
[7]: Exit program
----------------------
5
THISI SACEA SARCI PHERT EST
----------------------
[1]: Enter a phrase
[2]: Enter a key
[3]: Encrypt phrase
[4]: Decrypt phrase
[5]: Print phrase
[6]: Print key
[7]: Exit program
----------------------
&