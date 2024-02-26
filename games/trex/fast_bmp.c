#include "main.h"

 uint8_t xs;
 uint8_t ws;
 uint8_t hs;

 uint8_t* put_sprite_3;
 uint8_t* screen1 = (uint8_t*) SCREEN;

unsigned int scr_adr = SCREEN;
uint8_t st;

void put_sprite(char x,char y);

void create_table(void)
{
#asm

	LXI D,0
	LXI H,06900h
	MVI A,32
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
#endasm
}




//             6       4       2
void put_tile(char x,char y, char st) // ����� ������� �� �������� 
{
// ������������ ������ ������� ��������
    #asm
    
        ld hl,4; y
        add hl,sp
        ld b,(hl) ; ��������� Y � B
     
         ld hl,6; x
        add hl,sp
        ld c,(hl) ; ��������� X � C
    
         ld hl,2; st
         add hl,sp
         ld a,(hl) ;
         sta _st
            LXI  H,0
            DAD  SP
            SHLD  spsave5
            ;��������� ����
        mov l, b
        mvi h, 0
        dad h
        lxi d, 06900h; 
        dad d ;������� ���������� hl � de
        mov e, m
        inx h
        mov d, m
        lhld _screen1; (�������� ����� ���� �������� �������)
        dad d
        xchg
        mov l,c; �������� ���������� � � HL
        mvi h, 0
        dad d ;�������� � DE
        xchg
        ; ���� �� ��������� ����� ������ �������� ������� � ������ ��������� (� DE �������� ����� ������ �� ��������� �� �����������)

        lhld  _put_sprite_3; � HL ��������� ����� ������� 
        SPHL ;  ��������� ���� ����� � ���� (HL ->SP) �� ���� ����� ������� � �����
        xchg ; ����� ������ ������ � HL 
        shld _scr_adr;
        lxi d, 78

        lda _st
        cpi 0
        jz ext
vivd:
        lhld  _scr_adr; ��������� ����� ������
        inx h; x=x+1
        shld _scr_adr;
 
        POP  B   ; ����������� ���� �� ����� (�������� ����� � �����)
        MOV  M,C ;1 ������ 2 �����
        DAD D; ���� �� 1 ������
        MOV  M,B ;2 ������ 2 �����
        DAD D; �������� 78
        
        POP  B   ; ����������� ���� �� ����� (�������� ����� � �����)
        MOV  M,C ;1 ������ 2 �����
        DAD D; ���� �� 1 ������
        MOV  M,B ;2 ������ 2 �����
        DAD D; �������� 78

        POP  B   ; ����������� ���� �� ����� (�������� ����� � �����)
        MOV  M,C ;1 ������ 2 �����
        DAD D; ���� �� 1 ������
        MOV  M,B ;2 ������ 2 �����
        DAD D; �������� 78

       
        
        dcr a
        jnz vivd
ext:
  ;����� ����������� ���� � �����
  LHLD  spsave5
  SPHL
  RET

#endasm
}


//                   4      2     
void put_sprite(char x,char y)
{
    #asm
   
        ld hl,2; y
        add hl,sp
        ld b,(hl) ; ��������� Y � B
     
        inc hl
        inc hl
        ld c,(hl) ; ��������� X � C
        
            LXI  H,0
            DAD  SP
            SHLD  spsave5
            ;��������� ����

        mov l, b
        mvi h, 0
        dad h
        lxi d, 06900h; 
        dad d ;������� ���������� hl � de
        mov e, m
        inx h
        mov d, m
         lhld _screen1; (�������� ����� ���� �������� �������)
        dad d
        xchg
        mov l,c; �������� ���������� � � HL
        mvi h, 0
        dad d ;�������� � DE
        xchg
        ; ���� �� ��������� ����� ������ �������� ������� � ������ ��������� (� DE �������� ����� ������ �� ��������� �� �����������)
        lhld  _put_sprite_3
        ld a,(hl) ; �������� ������ �������
        sta _ws
        inc  hl
        ld a,(hl)
        sta _hs
        inc hl

        SPHL ;  ��������� ���� ����� � ���� (HL ->SP) �� ���� ����� ������� � �����
        xchg ; ����� ������ ������ � HL 
        
            lda _hs;
            lxi d, 79
            cma
            add e
            mov e, a
  
 ;����� ������� �������� ������ � ����� �������� ����� ��������, � HL �������� ����� ������ �� ��������� �� �������� ����������� � DE �������� �������� ��� ��������� ������
start_draw5:




lda _hs;
    ora a
    rar
viv5:
  POP  B   ; 
  MOV  M,C ;1
  ;dcr a;
  ;jz dal5;
  INX  H
  MOV  M,B ;2
  INX  H
  dcr a;
  
  jnz viv5;

dal5:
  DAD  D;     ��������� ������ �������
  lda _ws;
  dcr a
  jz exit_draw5
  sta _ws
  jmp start_draw5
 
exit_draw5:
  ;����� ����������� ���� � �����
  LHLD  spsave5
  SPHL
  RET
spsave5:
  defw  1
qq5:
    defb 0
    defb 0
#endasm
}


void clrscr(void)
{
#asm
lxi h,0
mov d,h
mov e,l
dad sp
mov b,h
mov c,l
lxi h, 7594h; ������ �������� ������� + �� �����
sphl
mvi a, 156
mmm:
 push d
 push d
 push d
 push d
 push d
 push d
 push d
 push d
 push d
 push d
 push d
 push d
 push d
 push d
 push d
 push d
dcr a
jnz mmm
mov h,b
mov l,c
sphl
#endasm
}

void put_cactus(char x,char y, char st)
{
// ������������ ������ ������� ��������
    #asm
    
        ld hl,4; y
        add hl,sp
        ld b,(hl) ; ��������� Y � B
     
         ld hl,6; x
        add hl,sp
        ld c,(hl) ; ��������� X � C
    
         ld hl,2; st
         add hl,sp
         ld a,(hl) ;
         sta _st
            LXI  H,0
            DAD  SP
            SHLD  spsave5
            ;��������� ����
        mov l, b
        mvi h, 0
        dad h
        lxi d, 06900h; 
        dad d ;������� ���������� hl � de
        mov e, m
        inx h
        mov d, m
        lhld _screen1; (�������� ����� ���� �������� �������)
        dad d
        xchg
        mov l,c; �������� ���������� � � HL
        mvi h, 0
        dad d ;�������� � DE
        xchg
        ; ���� �� ��������� ����� ������ �������� ������� � ������ ��������� (� DE �������� ����� ������ �� ��������� �� �����������)

        lhld  _put_sprite_3; � HL ��������� ����� ������� 
        SPHL ;  ��������� ���� ����� � ���� (HL ->SP) �� ���� ����� ������� � �����
        xchg ; ����� ������ ������ � HL 
        shld _scr_adr;
        lxi d, 78

        lda _st
        cpi 0
        jz ext1
vivd1:
        lhld  _scr_adr; ��������� ����� ������
        inx h; x=x+1
        shld _scr_adr;
 
        POP  B   ; ����������� ���� �� ����� (�������� ����� � �����)
        MOV  M,C ;1 ������ 2 �����
        DAD D; ���� �� 1 ������
        MOV  M,B ;2 ������ 2 �����
        DAD D; �������� 78
        
        POP  B   ; ����������� ���� �� ����� (�������� ����� � �����)
        MOV  M,C ;1 ������ 2 �����
        DAD D; ���� �� 1 ������
        MOV  M,B ;2 ������ 2 �����
        DAD D; �������� 78

        POP  B   ; ����������� ���� �� ����� (�������� ����� � �����)
        MOV  M,C ;1 ������ 2 �����
        DAD D; ���� �� 1 ������
        MOV  M,B ;2 ������ 2 �����
        DAD D; �������� 78

        POP  B   ; ����������� ���� �� ����� (�������� ����� � �����)
        MOV  M,C ;1 ������ 2 �����
        DAD D; ���� �� 1 ������
        MOV  M,B ;2 ������ 2 �����
        DAD D; �������� 78
        
        POP  B   ; ����������� ���� �� ����� (�������� ����� � �����)
        MOV  M,C ;1 ������ 2 �����
        DAD D; ���� �� 1 ������
        MOV  M,B ;2 ������ 2 �����
        DAD D; �������� 78

       
        
        dcr a
        jnz vivd1
ext1:
  ;����� ����������� ���� � �����
  LHLD  spsave5
  SPHL
  RET

#endasm
}


void put_ptero(char x,char y, char st)
{
// ������������ ������ ������� ��������
    #asm
    
        ld hl,4; y
        add hl,sp
        ld b,(hl) ; ��������� Y � B
     
         ld hl,6; x
        add hl,sp
        ld c,(hl) ; ��������� X � C
    
         ld hl,2; st
         add hl,sp
         ld a,(hl) ;
         sta _st
            LXI  H,0
            DAD  SP
            SHLD  spsave5
            ;��������� ����
        mov l, b
        mvi h, 0
        dad h
        lxi d, 06900h; 
        dad d ;������� ���������� hl � de
        mov e, m
        inx h
        mov d, m
        lhld _screen1; (�������� ����� ���� �������� �������)
        dad d
        xchg
        mov l,c; �������� ���������� � � HL
        mvi h, 0
        dad d ;�������� � DE
        xchg
        ; ���� �� ��������� ����� ������ �������� ������� � ������ ��������� (� DE �������� ����� ������ �� ��������� �� �����������)

        lhld  _put_sprite_3; � HL ��������� ����� ������� 
        SPHL ;  ��������� ���� ����� � ���� (HL ->SP) �� ���� ����� ������� � �����
        xchg ; ����� ������ ������ � HL 
        shld _scr_adr;
        lxi d, 78

        lda _st
        cpi 0
        jz ext2
vivd2:
        lhld  _scr_adr; ��������� ����� ������
        inx h; x=x+1
        shld _scr_adr;
 
        POP  B   ; ����������� ���� �� ����� (�������� ����� � �����)
        MOV  M,C ;1 ������ 2 �����
        DAD D; ���� �� 1 ������
        MOV  M,B ;2 ������ 2 �����
        DAD D; �������� 78
        
        POP  B   ; ����������� ���� �� ����� (�������� ����� � �����)
        MOV  M,C ;1 ������ 2 �����
        DAD D; ���� �� 1 ������
        MOV  M,B ;2 ������ 2 �����
        DAD D; �������� 78

        POP  B   ; ����������� ���� �� ����� (�������� ����� � �����)
        MOV  M,C ;1 ������ 2 �����
        DAD D; ���� �� 1 ������
        MOV  M,B ;2 ������ 2 �����
        DAD D; �������� 78

        POP  B   ; ����������� ���� �� ����� (�������� ����� � �����)
        MOV  M,C ;1 ������ 2 �����
        DAD D; ���� �� 1 ������
        MOV  M,B ;2 ������ 2 �����
        DAD D; �������� 78
        
      
       
        
        dcr a
        jnz vivd2
ext2:
  ;����� ����������� ���� � �����
  LHLD  spsave5
  SPHL
  RET

#endasm
}