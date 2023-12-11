#include "sprite.h"
#include "res.h"
extern uchar* radio86rkVideoMem;
extern uint* put_sprite_3;
//---------------------------------------------------------------------------
ST_SPRITE Sprite[SPRITE_MAX_CNT];

uint8_t xs;
uint8_t ys;
uint8_t ws;
uint8_t hs;

/*
void put_sprite(char x,char y)
{
    #asm
   
        ld hl,2; y
        add hl,sp
        ld b,(hl) ; ��������� Y � B
        inc hl
        inc hl
        ld c,(hl) ; ��������� X � C
*/

void put_sprite_wh(char x,char y)
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
            SHLD  spsave
            ;��������� ����

       ; lda _ys; _put_sprite_2; �������� � � ���������� y 
       ; mov b,a     ; ��������� Y � B
       ; lda _xs; _put_sprite_1; �������� � � ���������� x 
       ; mov c,a     ; ��������� X � C
        mov l, b
        mvi h, 0
        dad h
        lxi d, 06b00h; 
        dad d ;������� ���������� hl � de
        mov e, m
        inx h
        mov d, m
         lhld _radio86rkVideoMem; (�������� ����� ���� �������� �������)
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
            mvi a,8
            lxi d, 79
            cma
            add e
            mov e, a
;������ �������������, 8�6 �������� ������� �������� ��� ��������
 mvi a,6 
 ;����� ������� �������� ������ � ����� �������� ����� ��������, � HL �������� ����� ������ �� ��������� �� �������� ����������� � DE �������� �������� ��� ��������� ������
start_draw:

  POP  B   ; 
  MOV  M,C ;1
  INX  H
  MOV  M,B ;2
  INX  H
  POP  B   ; 
  MOV  M,C ;3
  INX  H
  MOV  M,B ;4
  INX  H
  POP  B   ; 
  MOV  M,C ;5
  INX  H
  MOV  M,B ;6
  INX  H
  POP  B   ; 
  MOV  M,C ;7
  INX  H
  MOV  M,B ;8
  INX  H


  DAD  D;     ��������� ������ �������
  dcr a
  jnz start_draw
  
 
exit_draw:
  ;����� ����������� ���� � �����
  LHLD  spsave
  SPHL
  RET
spsave:
  defw  1
qq:
    defb 0
    defb 0
#endasm
}


void DrawBmp(s8 sx, s8 sy, u8* p)
{
 put_sprite_3 = &p[0];
 put_sprite_wh(sx>>1,sy>>1);


}

//---------------------------------------------------------------------------
void SpriteInit(void)
{
	_memset(&Sprite, 0x00, sizeof(ST_SPRITE) * SPRITE_MAX_CNT);
}
//---------------------------------------------------------------------------
void SpriteReset(void)
{
	u8 i;

	for(i=0; i<SPRITE_MAX_CNT; i++)
	{
		if(Sprite[i].isUse == TRUE)
		{
			Sprite[i].isUse = FALSE;
		}
	}
}
//---------------------------------------------------------------------------
void SpriteDraw(void)
{
	u8 i;

	for(i=0; i<SPRITE_MAX_CNT; i++)
	{
		if(Sprite[i].isUse == TRUE)
		{
                      
			DrawBmp(Sprite[i].sx, Sprite[i].sy, Sprite[i].pDat);
		}
	}
}
void SpriteDrawEmpty(void)
{
	u8 i;

	for(i=0; i<SPRITE_MAX_CNT; i++)
	{
		if(Sprite[i].isUse == TRUE)
		{
                      
			DrawBmp(Sprite[i].sx, Sprite[i].sy, Empty_sprite);
		}
	}
}
//---------------------------------------------------------------------------
void SpriteSetPanel(u8 num, s16 fsx, s16 fsy, u8* pDat)
{
	Sprite[num].sx    = FIX2NUM(fsx);
	Sprite[num].sy    = FIX2NUM(fsy);
	Sprite[num].pDat  = pDat;
	Sprite[num].isUse = TRUE;
}
//---------------------------------------------------------------------------
void SpriteSetPanelNormal(u8 num, s16 fsx, s16 fsy, u8 chr)
{
	SpriteSetPanel(num, fsx, fsy, (u8*)ResPanelNormalList[chr]);
}
//---------------------------------------------------------------------------
void SpriteSetPanelReverse(u8 num, s16 fsx, s16 fsy, u8 chr)
{
	SpriteSetPanel(num, fsx, fsy, (u8*)ResPanelReverseList[chr]);
}
//---------------------------------------------------------------------------
void SpriteSetPanelScale(u8 num, s16 fsx, s16 fsy, u8 chr, u8 var)
{
	//ASSERT(chr < 2);

	if(chr == 0)
	{
		SpriteSetPanel(num, fsx, fsy, (u8*)ResPanelScale1List[var]);
	}
	else
	{
		SpriteSetPanel(num, fsx, fsy, (u8*)ResPanelScale2List[var]);
	}
}
//---------------------------------------------------------------------------
void SpriteDelPanel(s16 fsx, s16 fsy)
{
	u8 sx = FIX2NUM(fsx);
	u8 sy = FIX2NUM(fsy);
	u8 i;

	for(i=0; i<SPRITE_MAX_CNT; i++)
	{
		if(Sprite[i].isUse == TRUE && Sprite[i].sx == sx && Sprite[i].sy == sy)
		{
			Sprite[i].isUse = FALSE;
		}
	}
}
