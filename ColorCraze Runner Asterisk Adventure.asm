[org 0x0100]
jmp start

position: dw 0
score: dw 0
flag: dw 1
counter: dw 0
oldisr: dd 0
oldTimer: dd 0
endFlag: dw 0
GameEnd: db 'The game is over'

greenRed:
	push es
	push ax
	push di
	
	mov ax, 0xb800
	mov es, ax

	mov word [es:146], 0x2220
	mov word [es:240], 0x2220
	mov word [es:324], 0x2220
	mov word [es:414], 0x2220
	mov word [es:602], 0x2220
	mov word [es:840], 0x2220
	mov word [es:902], 0x2220
	mov word [es:1500], 0x2220
	mov word [es:2650], 0x2220
	mov word [es:3042], 0x2220
	mov word [es:2024], 0x2220	
	mov word [es:3800], 0x2220
	mov word [es:3540], 0x2220
	mov word [es:2870], 0x2220
	mov word [es:1900], 0x2220
	mov word [es:1024], 0x2220
	mov word [es:2242], 0x2220
	mov word [es:2388], 0x2220
	mov word [es:2744], 0x2220	
	mov word [es:3576], 0x2220
	mov word [es:2890], 0x2220
	mov word [es:2324], 0x2220
	mov word [es:2992], 0x2220
	mov word [es:1054], 0x2220
	
	mov word [es:2840], 0x4220
	mov word [es:3000], 0x4220
	mov word [es:1450], 0x4220
	mov word [es:290], 0x4220
	mov word [es:650], 0x4220
	mov word [es:1042], 0x4220
	mov word [es:3480], 0x4220
	mov word [es:3024], 0x4220
	mov word [es:2096], 0x4220
	mov word [es:2038], 0x4220
	mov word [es:3700], 0x4220
	mov word [es:2750], 0x4220
	mov word [es:1090], 0x4220
	
	pop di
	pop ax
	pop es
	ret

clrscr:
	push es
	push ax
	push di
	mov di, 0
	mov ax, 0xb800
	mov es, ax
loop1:
	mov word[es:di], 0x0720
	add di, 2
	cmp di, 4000
	jnz loop1

	pop di
	pop ax
	pop es	
	ret

print: 
	push bp
	mov bp, sp
	push ax
	push es
	
	mov di, 156
	mov ax, 0xb800
	mov es, ax
	mov word ax, [cs:score]
	mov bx, 10
	mov cx, 0
	
digits:		;Pushing digits for score
	mov dx, 0
	div bx
	add dl, 0x30
	mov dh, 0x07
	push dx
	inc cx
	cmp ax, 0
	jnz digits
	
nextDigit:		;Popping and printing the digits
	pop dx
	mov [es:di], dx
	add di, 2
	loop nextDigit
	
	mov di, [bp+4]	; Position
	mov si, [bp+6]	; last pos
	mov al, 0x2A
	mov ah, 0x07
	
	;Checking if new position is a red block
	cmp word [es:di], 0x4220
	jnz printBack
	mov word [cs:endFlag], 1	;If red block, end game
	
printBack:	
	;Checking if new position is a green block
	cmp word[es:di], 0x2220
	jnz printBack2
	inc word [cs:score]
	
printBack2:
	;Printing asterisk and removing last asterisk
	mov [es:di], ax
	mov word [es:si], 0x0720
	
	pop es
	pop ax
	pop bp
	ret 4

end2: 
	jmp end3
timer: 
	push ax
	
	;Counter to wait for a second
	inc word [cs:counter]
	cmp word [cs:counter], 18	
	jnz end2
	mov word[cs:counter], 0
	
firstLine:
	;Right
	cmp word [cs:flag], 1
	jnz secondLine 
	push word [cs:position]		;Pushing old position to be to be removed
	
	cmp word[cs:position], 3998		;Checking if at bottom right corner for next position
	jl normal
	mov word[cs:position], 3840
	jmp end1
normal:
	add word [cs:position], 2
	jmp end1
	
secondLine:  
	;Down
	cmp word[cs:flag], 2
	jnz thirdLine
	push word[cs:position]		;Pushing old position to be to be removed
	
	cmp word[cs:position], 3840		;Checking if at bottom of screen for next position
	jl normal1
	mov ax, 4000
	sub word ax, [cs:position]
	mov word [cs:position], ax
	jmp end1
normal1:
	add word[cs:position], 160
	jmp end1

thirdLine: 
	;Left
	cmp word [cs:flag], 3
	jnz fourthLine
	push word[cs:position]	;Pushing old position to be to be removed
	
	cmp word[cs:position], 0	;Checking if at top left corner of screen for next position
	jg normal2
	mov word[cs:position], 156
	jmp end1
normal2:	
	sub word [cs:position], 2
	jmp end1	
	
fourthLine:
	;Up
	cmp word [cs:flag], 4
	jnz firstLine
	push word[cs:position]	;Pushing old position to be to be removed
	
	cmp word[cs:position], 160	;Checking if at top of screen for next position
	jg normal3
	mov ax, 4000
	sub word ax, [cs:position]
	mov word [cs:position], ax
	jmp end1	
normal3:
	sub word [cs:position], 160

end1: 
	push word [cs:position]		;Pushing new position to be printed
	call print

end3:
	pop ax
	jmp far [cs:oldTimer]

kbisr:
	push ax
	push es
	push di
	
	in al, 0x60
	
	;Up
	cmp al, 0x48
	jnz next
	mov word [cs:flag], 4
	jmp end4
	
next:
	;Down
	cmp al, 0x50
	jnz next2
	mov word [cs:flag], 2
	jmp end4
	
next2:
	;Left
	cmp al, 0x4B
	jnz next3
	mov word [cs:flag], 3
	jmp end4
	
next3:
	;Right
	cmp al, 0x4D
	jnz end4
	mov word [cs:flag], 1
	
end4:
	pop di
	pop es
	pop ax
	jmp far [cs:oldisr]

start:
	call clrscr
	call greenRed
	
	mov ax, 0
	mov es, ax
	mov ax, [es:8*4]
	mov [oldTimer], ax
	mov ax,[es:8*4+2]
	mov [oldTimer+2], ax
	cli
	mov word [es:8*4], timer
	mov word [es:8*4+2], cs
	sti
	mov ax, [es:9*4]
	mov [oldisr], ax
	mov ax,[es:9*4+2]
	mov[oldisr+2], ax
	cli
	mov word[es:9*4], kbisr
	mov word [es:9*4+2], cs
	sti
	
infiniteLoop:
	cmp word [endFlag], 1
	jnz infiniteLoop
	
	mov ax, 0
	mov es, ax
	cli
	mov ax, [oldTimer]
	mov [es:8*4], ax
	mov ax, [oldTimer+2]
	mov [es:8*4+2], ax
	sti
	cli
	mov ax, [oldisr]
	mov [es:9*4], ax
	mov ax, [oldisr+2]
	mov [es:9*4+2], ax
	sti
	call clrscr
	
	mov ax, 0xb800
	mov es, ax
	mov ah, 0x07
	mov si, 0
	mov cx, 16
	mov di, 160
loop2:	
	mov al, [GameEnd+si]
	mov [es:di], ax
	add di, 2
	inc si
	cmp si, cx
	jne loop2
		
mov ax, 0x4c00
int 21h