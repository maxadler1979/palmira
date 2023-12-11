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
        ld b,(hl) ; сохранить Y в B
        inc hl
        inc hl
        ld c,(hl) ; сохранить X в C
*/

void put_sprite_wh(char x,char y)
{
    #asm
            ld hl,2; y
			add hl,sp
			ld b,(hl) ; сохранить Y в B
			inc hl
			inc hl
			ld c,(hl) ; сохранить X в C
    
            LXI  H,0
            DAD  SP
            SHLD  spsave
            ;сохранили стек

       ; lda _ys; _put_sprite_2; загрузим в А координату y 
       ; mov b,a     ; сохранить Y в B
       ; lda _xs; _put_sprite_1; загрузим в А координату x 
       ; mov c,a     ; сохранить X в C
        mov l, b
        mvi h, 0
        dad h
        lxi d, 06b00h; 
        dad d ;сложить содержимое hl и de
        mov e, m
        inx h
        mov d, m
         lhld _radio86rkVideoMem; (загрузим адрес куда выводить графику)
        dad d
        xchg
        mov l,c; загрузим координату х в HL
        mvi h, 0
        dad d ;прибавим к DE
        xchg
        ; выше мы вычислили адрес памяти экранной области с учетом координат (в DE хранится адрес экрана со смещением по координатам)

        lhld  _put_sprite_3; в HL поместили адрес спрайта 
        SPHL ;  сохранили этот адрес в стек (HL ->SP) то есть адрес спрайта в стеке
        xchg ; адрес экрана теперь в HL 
            mvi a,8
            lxi d, 79
            cma
            add e
            mov e, a
;спрайт фиксированный, 8х6 символов поэтому упрощаем для быстроты
 mvi a,6 
 ;перед началом шустрого вывода в стеке хранится адрес картинки, в HL хранится адрес экрана со смещением по заданным координатам в DE хранится смещение для следующей строки
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


  DAD  D;     следующая строка спрайта
  dcr a
  jnz start_draw
  
 
exit_draw:
  ;далее восстановим стек и выход
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
