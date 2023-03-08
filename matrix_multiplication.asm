			Org 0000h
		
RS 			Equ  	P1.3   ;instruction reg
E			Equ		P1.2
			Mov 61h,#0 ; data counter
			
			mov 60h,#10h  
			mov r0,#20H ;matrix a
Main:		
		
			Clr RS		 ; Instruction register  

			Call FuncSet		
	
			Call DispCon		; Turn display and cusor on
			
			Call shift		;  shift cursor to the right
			mov 65h,#0h
			
Next:		Call ScanKeyPad
			SetB RS				;
				
			Clr A
			Mov A,R7
			Call SendChar		;Display the key that is pressed.
			
			Cjne R7,#'*',num1	;Check for "*"
				jmp store1
num1 :     mov a,65h
			mov b,#10h
			mul ab
			add a,r6	
			mov 65h,a
			jmp next


store1:
			mov @r0,65h   ;r6
			mov 65h,#00h
			inc r0		
			mov a,60h
			mov b,61h
			inc b
			mov 61h,b
			call clcd
			cjne a,b,Next
			mov 61h,#0H
			mov @r0,#0 

	


mov r0,#30H ;matrix b
mov 65h,#00h

Next2:		Call ScanKeyPad
			SetB RS				;
				
			Clr A
			Mov A,R7
			Call SendChar		;Display the key that is pressed.
			Cjne R7,#'*',num2	;Check for "*"
			jmp store2

num2 :     mov a,65h
			mov b,#10h
			mul ab
			add a,r6	
			mov 65h,a
			jmp Next2


store2:  	mov @r0,65h 
			mov 65h,#00h
			inc r0	
			mov a,60h
			mov b,61h
			inc b
			mov 61h,b
			call clcd
			cjne a,b,Next2
			
;---------------------------------------------------------
;A*B	
mov 60h,#20h ; matrix A
mov 61h,#30h ; matrix B
mov 62h,#40h ; Result A*B
mov 63h,#70h ; for display

mov r3,#04h
mov r4,#04h
mov r5,4

loop3:
mov r6,5

loop2:
mov 50h,#00h ; sum
mov r4,5

mov r0,60h
mov r1,61h
loop1:
mov a,@r0
mov b,@r1
mul ab
mov b,50h
add a,b
mov 50h,a

inc r0
mov a,r1
add a,#04h
mov r1,a

dec r4
cjne r4,#0h,loop1

mov 60h,r0
mov 61h,r1

mov 3fh,#00h


mov r0,62h
mov r1,63h
mov a,50h
mov @r0,a
add a,#30h
mov @r1,a
inc r0
inc r1

mov 62h,r0
mov 63h,r1



mov a,60h
subb a,#04h
mov 60h,a


mov a,61h
subb a,#0Eh
dec a
mov 61h,a




dec r6
cjne r6,#0h,loop2

mov a,60h
add a,#04h  ;;;;
mov 60h,a
mov 61h,#20h
dec r3

cjne r3,#0h,loop3


MOV 50H,#0h


;------------ Display result ---------------------


mov r0,40h
dis: 	

		SetB RS			;
	Clr a
	mov a,@r0
	add a,#30h   
	inc r0
	Call SendChar		;Display the key that is pressed.
	Cjne r0,#0h,dis	;Check for last digit
			jmp EndHere


;;;


	















;-------------------------
EndHere:	Jmp $


FuncSet:	Clr  P1.7		
			Clr  P1.6		
			SetB P1.5	
			Clr  P1.4		 
	
			Call Pulse

			Call Delay		
			Call Pulse
							
			SetB P1.7		;
			Clr  P1.6
			Clr  P1.5
			Clr  P1.4
			
			Call Pulse
			
			Call Delay
			Ret

DispCon:	Clr P1.7		
			Clr P1.6		
			Clr P1.5		
			Clr P1.4		

			Call Pulse

			SetB P1.7		
			SetB P1.6		
			SetB P1.5		
			SetB P1.4		
			Call Pulse

			Call Delay		
			Ret


shift  :	Clr P1.7		
			Clr P1.6		
			Clr P1.5	
			Clr P1.4		

			Call Pulse

			Clr  P1.7		
			SetB P1.6		
			SetB P1.5	
			Clr  P1.4		
 
			Call Pulse

			Call Delay		
			Ret


Pulse:		SetB E	
			Clr  E		
			Ret

			
SendChar:	Mov C, ACC.7	
			Mov P1.7, C		
			Mov C, ACC.6	
			Mov P1.6, C		
			Mov C, ACC.5	
			Mov P1.5, C		
			Mov C, ACC.4	
			Mov P1.4, C		
	
			Call Pulse

			Mov C, ACC.3	
			Mov P1.7, C		
			Mov C, ACC.2	
			Mov P1.6, C			
			Mov C, ACC.1		
			Mov P1.5, C			
			Mov C, ACC.0		
			Mov P1.4, C			

			Call Pulse

			Call Delay			
			Mov R1,#55h
			Ret



Delay:		Mov r1, #50
			Djnz r1, $
			Ret



ScanKeyPad:	CLR P0.3		
			CALL IDCode0		;Call scan column
			SetB P0.3			;Set Row 3
			JB F0,Done  		;If F0 is set, end scan 
						
			;Scan Row2
			CLR P0.2			;Clear Row2
			CALL IDCode1		;Call scan column subroutine
			SetB P0.2			;Set Row 2
			JB F0,Done		 	;If F0 is set, end scan 						

			;Scan Row1
			CLR P0.1			;Clear Row1
			CALL IDCode2		;Call scan column subroutine
			SetB P0.1			;Set Row 1
			JB F0,Done			;If F0 is set, end scan

			;Scan Row0			
			CLR P0.0			;Clear Row0
			CALL IDCode3		;Call scan column subroutine
			SetB P0.0			;Set Row 0
			JB F0,Done			;If F0 is set, end scan 
														
			JMP ScanKeyPad		;Go back to scan Row3
							
Done:		Clr F0		        ;Clear F0 flag before exit
			Ret



IDCode0:	JNB P0.4, KeyCode03	;If Col0 Row3 is cleared - key found
			JNB P0.5, KeyCode13	;If Col1 Row3 is cleared - key found
			JNB P0.6, KeyCode23	;If Col2 Row3 is cleared - key found
			RET					

KeyCode03:	SETB F0			;Key found - set F0
			Mov R7,#'3'
			Mov r6,#3h		;Code for '3'
			RET				

KeyCode13:	SETB F0			;Key found - set F0
			Mov R7,#'2'
			mov r6,#2	;Code for '2'
			RET				

KeyCode23:	SETB F0			;Key found - set F0
			Mov R7,#'1'	
			Mov r6,#1h	;Code for '1'
			RET				

IDCode1:	JNB P0.4, KeyCode02	;If Col0 Row2 is cleared - key found
			JNB P0.5, KeyCode12	;If Col1 Row2 is cleared - key found
			JNB P0.6, KeyCode22	;If Col2 Row2 is cleared - key found
			RET					

KeyCode02:	SETB F0			;Key found - set F0
			Mov R7,#'6'		;Code for '6'
			Mov r6,#6h
			RET				

KeyCode12:	SETB F0			;Key found - set F0
			Mov R7,#'5'		;Code for '5'
			Mov r6,#5h
			RET				

KeyCode22:	SETB F0			;Key found - set F0
			Mov R7,#'4'	
			Mov r6,#4h	;Code for '4'
			RET				

IDCode2:	JNB P0.4, KeyCode01	;If Col0 Row1 is cleared - key found
			JNB P0.5, KeyCode11	;If Col1 Row1 is cleared - key found
			JNB P0.6, KeyCode21	;If Col2 Row1 is cleared - key found
			RET					

KeyCode01:	SETB F0			;Key found - set F0
			Mov R7,#'9'	
			Mov r6,#9h	;Code for '9'
			RET				

KeyCode11:	SETB F0			;Key found - set F0
			Mov R7,#'8'	
			Mov r6,#8h	;Code for '8'
			RET				

KeyCode21:	SETB F0			;Key found - set F0
			Mov R7,#'7'	
			Mov r6,#7h	;Code for '7'
			RET				

IDCode3:	JNB P0.4, KeyCode00	;If Col0 Row0 is cleared - key found
			JNB P0.5, KeyCode10	;If Col1 Row0 is cleared - key found
			JNB P0.6, KeyCode20	;If Col2 Row0 is cleared - key found
			RET					

KeyCode00:	SETB F0			;Key found - set F0
			Mov R7,#'#'		;Code for '#' 
			RET				

KeyCode10:	SETB F0			;Key found - set F0
			Mov R7,#'0'	
			Mov r6,#0h	;Code for '0'
			RET				

KeyCode20:	SETB F0			;Key found - set F0
			Mov R7,#'*'	   	;Code for '*' 
			RET						


CursorPos:	Clr RS
			SetB P1.7		; Sets the DDRAM address
			SetB P1.6		; Set address. Address starts here - '1'
			Clr P1.5		; 									 '0'
			Clr P1.4		; 									 '0' 
							; high nibble
			Call Pulse

			Clr P1.7		; 									 '0'
			Clr P1.6		; 									 '0'
			Clr P1.5		; 									 '0'
			Clr P1.4		; 									 '0'
							
			Call Pulse

			Call Delay		; wait for BF to clear	
			Ret	

home :
Clr RS
			clr P1.7		; Sets the DDRAM address
			clr P1.6		; Set address. Address starts here - '1'
			Clr P1.5		; 									 '0'
			Clr P1.4		; 									 '0' 
							; high nibble
			Call Pulse

			Clr P1.7		; 									 '0'
			Clr P1.6		; 									 '0'
			Clr P1.5		; 									 '0'
			Clr P1.4		; 									 '0'
							
			Call Pulse

			Call Delay		; wait for BF to clear	
			Ret	

 

;CLEAR lcd
clcd:
clr p1.3
call delay
clr p1.7
clr p1.6
clr p1.5
clr p1.4

setb p1.2
clr p1.2
call delay

clr p1.7
clr p1.6
CLR p1.5
SETB p1.4

setb p1.2
clr p1.2
call delay
call delay
call delay
ret






	
Stop:		Jmp $
	
			End
