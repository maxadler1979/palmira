SECTION code_user

PUBLIC _cleardot

extern _coordata

_cleardot:
        lhld _coordata
        mov b,l;
        mov c,h
	CALL GETDOT
	CMA
	ANA M
	MOV M,A
	RET


PUBLIC _drawdot

extern _coordata

_drawdot:
lhld _coordata
mov b,l;
mov c,h
	CALL GETDOT
	MOV B,A
	MOV A,M
	ORA B
	MOV M,A
	RET

GETDOT: ;B,C 
	LXI D,VISIONS
	MOV A,B
	RAR
	JNC NOF
	INX D
NOF:
	ANI 127
	MOV B,A
	MOV A,C
	RAR
	JNC NOS
	INX D
	INX D
NOS:
	ANI 127
	MOV C,A
	PUSH D
	CALL GPA
	POP D
	LDAX D
	RET



GPA:;B,C - X,Y 
	MOV A,C
	ADD A
	MOV L,A
	MVI H,06bh
	MOV E,M
	INX H
	MOV D,M
	MOV L,B
	MVI H,0
	DAD D
	XCHG
	LHLD VADDR
	DAD D
	RET



PUBLIC _create_tbl

_create_tbl:
	LXI D,0
	LXI H,6b00h
	MVI A,34
	LXI B,78
NTACK:
	MOV M,E
	INX H
	MOV M,D
	INX H
	XCHG
	DAD B
	XCHG
	DCR A
	JNZ NTACK
	RET
PUBLIC _get_key
_get_key:
extern _kb
     call 0F81Bh
     sta _kb
     ret

PUBLIC _fillRect

_fillRect:
;    
 extern _fr_a; start address a - fillRect_1
 extern _fr_w; weight rect w - fillRect_2
 extern _fr_h; height rect h - fillRect_3
 extern _fr_c; code to fill c - fillRect_4
 extern _radio86rkVideoBpl
    push b
    lda _radio86rkVideoBpl
    mov c, a
    mvi b, 0
    lhld _fr_a
    lda _fr_h
    mov d, a
    lda _fr_c
    mov e, a
fillRect_l1:  
    lda _fr_w
    push h
fillRect_l0:
    mov m, e
    inx h
    dcr a
    jnz fillRect_l0
    pop h
    dad b    
    dcr d
    jnz fillRect_l1
    pop b
    ret

PUBLIC _print_len
_print_len:
 extern _pr_dest; start address dest
 extern _pr_len;  len
 extern _pr_text; text

    shld _pr_text;
    push b
    xchg
    lhld _pr_dest;              
    lda  _pr_len;               
    mov b, a
print2m_loop:
    ldax d
   ora  a
    jz   print2m_ret
    ;ani  07Fh
print2m_ret:
    mov  m, a
    inx  h
    inx  d
    dcr b
    jnz  print2m_loop 

    pop b
  
  ret


PUBLIC _put_sprite

_put_sprite:
extern _put_sprite_1; x
extern _put_sprite_2; y
extern _put_sprite_3; sprite
;extern _radio86rkVideoMem
;extern _sm_y
;push b
;push d
;push h
  LXI  H,0
  DAD  SP
  SHLD  spsave

        lda _put_sprite_2; загрузим в А координату y 
        mov b,a     ; сохранить Y в B
        lda _put_sprite_1; загрузим в А координату x 
        mov c,a     ; сохранить X в C
        mov l, b
        mvi h, 0
        dad h
        lxi d, 06b00h; _sm_y
        dad d ;сложить содержимое hl и de
        mov e, m
        inx h
        mov d, m
        lxi h,VADDR; lhld _radio86rkVideoMem
        dad d
        xchg
        mov l,c; загрузим координату х в HL
        mvi h, 0
        dad d ;прибавим к DE
        xchg
        ; в DE хранится адрес экрана куда можно выводить строку
        lhld _put_sprite_3 ;прочитаем адрес спрайта и поместим в HL
        SPHL ; HL ->SP
        xchg ; поместим адрес экрана в HL
        LXI  D,78-4; в DE поместим смещение по y
        POP  B   ; 
  MOV  M,C ;1
  INX  H
  MOV  M,B ;2
  INX  H

  POP  B
  MOV  M,C ;3
  INX  H
  MOV  M,B ;4
  INX  H

  DAD  D;     следующая строка спрайта
		 
  POP  B
  MOV  M,C;5
  INX  H
  MOV  M,B;6
  INX  H

  POP  B
  MOV  M,C;7
  INX  H
  MOV  M,B;8
  INX  H

  DAD  D ;  следующая строка спрайта
  POP  B
  MOV  M,C;9
  INX  H
  MOV  M,B;10
  INX  H

  POP  B
  MOV  M,C;11
  INX  H
  MOV  M,B;12
  INX  H

  DAD  D;  следующая строка спрайта
  POP  B
  MOV  M,C;13
  INX  H
  MOV  M,B;14
  INX  H
  
  POP  B
  MOV  M,C;15
  INX  H
  MOV  M,B;16
  ;INX  H
 
  LHLD  spsave
  SPHL
  ;pop h
  ;pop d
  ;pop b
  RET
spsave:
  defw  1



VADDR: 
defw 6c42h; тут адрес видеопамяти

;cleardot стирает точку, а drawdot ставит, по положению B:C

VISIONS:
defb 1,2,16,4
