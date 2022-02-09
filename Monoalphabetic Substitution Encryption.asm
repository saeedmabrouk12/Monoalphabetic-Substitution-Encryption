org 100h

;we call library emu8086 to use get_string function
include 'emu8086.inc'




 
MOV AH, 06h    ; Scroll up function
XOR AL, AL     ; Clear entire screen
XOR CX, CX     ; Upper left corner CH=row, CL=column
MOV DX, 184FH  ; lower right corner DH=row, DL=column
MOV BH, 1Eh    ; YellowOnBlue
INT 10H        
mov ah,3    ; Get the current cursor position
mov bh,0
int 10h

   
         
           
; we use jump to save time of exectie lables 
jmp start

table1      dB 'aqbwcedretfyguhiiojpkalsmdnfogphqjrksltzuxvcwvxbynzm'

msg1        DB  'Enter the message: ', '$'

msg2        DB  'Encrypted message: ', '$'

msg3        DB  'Decrypted message: ', '$'

n_line      DB  0DH,0AH,'$'                 ;for new line

str         DB  256 DUP('$')                ;buffer string

enc_str     DB  256 DUP('$')                ;encrypted string

dec_str     DB  256 DUP('$')                ;decrypted string



start:
   
   
   
           
; print message  
mov ah,2    ; Set cursor position
mov bh,0
mov dl,30   ; New column. In an 80 column text mode this will just about center
            ; the 3 characters 
; We wanto to stay on the same row, so we don't change dh
int 10h 
LEA    dx,msg1
; output of a string at ds:dx
MOV    ah,09h
INT    21h ; read the string from standard input, result is stored in AL

LEA    DI,str   ;buffer string
CALL   GET_STRING ; print new line  

LEA    dx,n_line  ; output of a string at ds:dx
MOV    ah,09h
INT    21h                
           
                     
                     
; encrypt:   

LEA    bx, table1
LEA    si, str
LEA    di, enc_str   
mov    dx, bx  
mov    cx,0
CALL   process
                                          
; print message    
mov ah,2    ; Set cursor position
mov bh,0
mov dl,30   ; New column. In an 80 column text mode this will just about center
   ; the 3 characters 
; We wanto to stay on the same row, so we don't change dh
int 10h 
LEA    dx,msg2
; output of a string at ds:dx
MOV    ah,09h
INT    21h
; show result:
LEA    dx, enc_str
; output of a string at ds:dx
MOV    ah, 09
INT    21h
; print new line  

LEA    dx,n_line
; output of a string at ds:dx
MOV    ah,09h
INT    21h     
                
-           
                
; decrypt:          
              
LEA    bx, table1 
inc    bx
LEA    si, enc_str
LEA    di, dec_str   
mov    dx, bx  
mov    cx,1
CALL   process


mov    dx, bx
CALL   process

; print message  
mov ah,2    ; Set cursor position
mov bh,0
mov dl,30   ; New column. In an 80 column text mode this will just about center
inc dh            ; the 3 characters 
; We wanto to stay on the same row, so we don't change dh
int 10h 
LEA    dx,msg3
; output of a string at ds:dx
MOV    ah,09h
INT    21h
; show result:
LEA    dx, dec_str
; output of a string at ds:dx
MOV    ah, 09
INT    21h
; print new line
LEA    dx,n_line ; output of a string at ds:dx
MOV    ah,09h
INT    21h
           
           
           
; wait for any key...
mov    ah, 0
int    16h   





                   


process proc near

next_char:

 mov    al, [si]
 cmp    al, 'a'
 jb     end_of_string:
 cmp    al, 'z'
 ja     end_of_string:
         
            
 mov al,[bx]
 cmp  al,[si]
 je     x1
 inc bx
 inc bx
 
jmp    next_char 
           
x1:   

    cmp cx,1
    je yes   
    inc bx      
    mov    al  , [bx]
    mov    [di],    al
    inc    di  
    mov    bx, dx   
    inc si 
    jmp    next_char      
 yes:  
    dec bx      
    mov    al  , [bx]
    mov    [di],    al
    inc    di  
    mov    bx, dx   
    inc si  
    jmp    next_char                     
                     

skip:
 inc    si 
 jmp    next_char

end_of_string:
ret            

DEFINE_GET_STRING       ;predefined macro in umu8086.inc to read a s    tring input           

END