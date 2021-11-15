;***********************************************************************
;                        Example to interface the
;                  PKWARE Data Compression Library (TM)
;                                 with
;                           Assembly Language
;          Copyright 1990-1991, By PKWARE Inc.  All Rights Reserved.
;***********************************************************************/


CMP_BINARY equ 0
CMP_ASCII  equ 1

CR equ 0dh
LF equ 0ah

extrn IMPLODE:far

_text segment word public 'CODE'
_text ends


dgroup GROUP conss,_DATA,_bss,_stack
assume ds:dgroup,ss:dgroup


conss SEGMENT byte public 'conss'
CR_LF      db CR, LF, '$'
TEST_IN    db 'temp.edl',0
TEST_OUT   db 'temp.pak',0
CANTOPEN   db 'Unable to open input file$'
CANTCREATE db 'Unable to create output file$'
ERREXT     db 'Error in compressed file!$'
conss ends

_DATA SEGMENT word public 'data'
_DATA ends

_bss segment word public 'bss'
_bss ends

comm buffer:byte:35256
comm InHandle:word
comm OutHandle:word
comm Ctype:word
comm Dsize:word

_stack segment para stack 'stack'
x db 2048 dup(?)
_stack ends



_text segment
assume cs:_text

frame struc
  savebp dw ?
  retadr dd ?
  count  dd ?
  Buf    dd ?
frame ends

READDATA proc far
public READDATA

   push bp                              ; save
   mov bp,sp                            ; load ptr to parameters on stack
   push ds                              ; save

   mov ah,3fh                           ; Read from TEST.IN

   les bx,[bp+count]
   mov cx,es:[bx]                       ; Bytes to read

   mov bx,InHandle                      ; Handle
   lds dx,[bp+Buf]                      ; Buffer Address
   int 21h

   pop ds                               ; restore
   pop bp                               ; restore

ret 8

READDATA endp


WRITEDATA proc far
public WRITEDATA

   push bp                              ; save
   mov bp,sp                            ; load ptr to parameters on stack
   push ds                              ; save

   mov ah,40h                           ; Write data to TEST.CMP

   les bx,[bp+count]
   mov cx,es:[bx]                       ; Bytes to read

   mov bx,OutHandle                     ; Handle
   lds dx,[bp+Buf]                      ; Buffer Address
   int 21h

   pop ds                               ; restore
   pop bp                               ; restore

ret 8

WRITEDATA endp


PrintLine proc near

   mov ah,9
   int 21h

   mov ah,9
   mov dx,offset CR_LF
   int 21h
   ret

PrintLine endp


StartExe:
   mov ax,dgroup
   mov ds,ax
   mov bx,ss
   sub bx,ax
   mov cl,4
   shl bx,cl
   cli
   mov ss,ax
   add sp,bx
   sti

   mov ax,3d00h                         ; Open input file
   mov dx,offset dgroup:TEST_IN
   int 21h
   jnc INPUT_OPEN                       ; Error opening file

   mov dx,offset dgroup:CANTOPEN
   call PrintLine
   jmp Exit_To_DOS

INPUT_OPEN:
   mov InHandle,ax                      ; Save handle

   mov ah,3ch                           ; Create destination file
   xor cx,cx                            ; File attribute
   mov dx,offset dgroup:TEST_OUT        ; Filename from command line
   int 21h

   jnc OUTPUT_OPEN                      ; Error creating

   mov dx,offset dgroup:CANTCREATE      ; Error creating message
   call PrintLine

   mov bx,InHandle
   mov ah,3eh                           ; Close TEST.IN
   int 21h
   jmp Exit_To_DOS

OUTPUT_OPEN:
   mov OutHandle,ax                     ; Save handle

;Call Implode
   mov ax,offset _text:READDATA
   push cs
   push ax
   mov ax,offset _text:WRITEDATA
   push cs
   push ax

   mov ax,offset dgroup:buffer
   push ds
   push ax

   mov Ctype,CMP_BINARY
   mov ax,offset dgroup:Ctype
   push ds
   push ax

   mov Dsize,4096                       ; 4K Dictionary
   mov ax,offset dgroup:Dsize
   push ds
   push ax

   call IMPLODE

   mov bx,InHandle
   mov ah,3eh                           ; Close input
   int 21h

   mov ah,3eh
   mov bx,OutHandle                     ; Close output
   int 21h

Exit_To_DOS:
   mov ax,4c00h
   int 21h                              ; Exit to DOS

_text ends
end StartExe
