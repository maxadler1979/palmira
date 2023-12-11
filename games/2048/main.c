#include <string.h>
#include <stdint.h>
#include "main.h"
#include "rnd.h"
#include "anime.h"
#include "panel.h"
#include "score.h"
#include "sprite.h"

unsigned char kb=0;


ST_GAME Game;

extern uint8_t xs;
extern uint8_t ys;
extern uint8_t ws;
extern uint8_t hs;
extern uchar* radio86rkVideoMem;
void draw_main_screen(void)
{
        lcdPrintText("TINY", 0, 0);//OledDrawStr( 0, 0, "TINY");
	    lcdPrintText("2048", 0, 8);//OledDrawStr( 0, 1, "2048");
        lcdPrintText("SCORE", 97, 0);//OledDrawStr(16, 0, "SCORE");
	//lcdPrintText("Портировал", 18, 16); //OledDrawStr(17, 2, "BEST");  
}

void GameExecReset(void)
{
	AnimeInit();
	PanelInit();
	ScoreInit();
	SpriteInit();
	PanelMakeCell();
	PanelMakeCell();
	GameSetAct(GAME_EXEC_ANIME);
}
//---------------------------------------------------------------------------
void GameExecAnime(void)
{
	//PanelDraw();
	//ScoreDraw();

	SpriteDraw();
	AnimeExec();
	if(AnimeIsEnd() == FALSE)
	{
		return;
	}
        
	if(ScoreIs10() == TRUE || PanelIsGameOver() == TRUE)
	{
		GameSetAct(GAME_EXEC_OVER);
	}
	else
	{
		GameSetAct(GAME_EXEC_PLAY);
	}
}


void panel_clear(void)
{
    #asm
    
    
            LXI  H,0
            DAD  SP
            SHLD  spsave
            ;сохранили стек

        mvi c,16;//
        lxi h, 06b02h; 
        mov e, m
        inx h
        mov d, m
         lhld _radio86rkVideoMem; (загрузим адрес куда выводить графику)
        dad d
        xchg
        mov l,c; загрузим координату х в HL
        mvi h, 0
        dad d ;прибавим к DE
        ; выше мы вычислили адрес памяти экранной области с учетом координат (в DE хранится адрес экрана со смещением по координатам)
            mvi a,32; 
            lxi d, 79
            cma
            add e
            mov e, a
			mvi b,30; // очистим 30 строк
 
start_draw:

 mvi a,4; // 4 раза по 8 (очистим 32 символа по х)
viv:
  
  MVI  M,0 ;1
  INX  H
  MVI  M,0 ;2
  INX  H
  MVI  M,0 ;3
  INX  H
  MVI  M,0 ;4
  INX  H
  MVI  M,0 ;5
  INX  H
  MVI  M,0 ;6
  INX  H
  MVI  M,0 ;7
  INX  H
  MVI  M,0 ;8
  INX  H
  dcr a;
  jnz viv;
  DAD  D;     следующая строка очищаемой области
 
  dcr b
  jnz start_draw
 
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




//---------------------------------------------------------------------------
void GameExecPlay(void)
{
	//PanelDraw();
	ScoreDraw();
  
	SpriteDraw();

	

	if(GetInput()==KEY_up) //нажали кнопку вверх
	{
               
		PanelMoveUp(); //передвинем панель вверх
                
		GameSetAct(GAME_EXEC_JUDGE);
	}
	else if(GetInput()==KEY_right)
	{
                
		PanelMoveRight();
                //panel_clear();
		GameSetAct(GAME_EXEC_JUDGE);
	}
	else if(GetInput()==KEY_down)
	{
                
		PanelMoveDown();
//panel_clear();
		GameSetAct(GAME_EXEC_JUDGE);
	}
	else if(GetInput()==KEY_left)
	{
               // panel_clear();
		PanelMoveLeft();
                
		GameSetAct(GAME_EXEC_JUDGE);
                //panel_clear();
	}

	if(GetInput()==KEY_enter)
	{
        clear_screen();
        draw_main_screen();     
		ScoreSaveBest();
		GameSetAct(GAME_EXEC_RESET);
	}
}
//---------------------------------------------------------------------------
void GameExecJudge(void)
{
	//PanelDraw();
	//ScoreDraw();
	SpriteDraw();


	if(AnimeIsDispOnly() == FALSE)
	{
		PanelMakeCell();
	}

	GameSetAct(GAME_EXEC_ANIME);
}
//---------------------------------------------------------------------------
void GameExecOver(void)
{
	panel_clear();
	ScoreDraw();
	SpriteDraw();


	lcdPrintText("GAME", 0, 7);//OledDrawStr(0, 6, "GAME");

	if(ScoreIs10() == TRUE)
	{
		lcdPrintText("CLR", 0, 15);//OledDrawStr(0, 7, "CLEAR");
	}
	else
	{
		lcdPrintText("OVER", 0, 15);//OledDrawStr(0, 7, "OVER");
	}

	if(GetInput()==KEY_enter)
	{
                clear_screen();
                draw_main_screen();
		ScoreSaveBest();
		GameSetAct(GAME_EXEC_RESET);
	}
}
//---------------------------------------------------------------------------
void GameSetAct(u8 act)
{
	Game.act = act;
}








void GameLoop(void)
{
	switch(Game.act)
	{
		case GAME_EXEC_RESET: GameExecReset(); break;
		case GAME_EXEC_ANIME: GameExecAnime(); break;
		case GAME_EXEC_PLAY:  GameExecPlay();  break;
		case GAME_EXEC_JUDGE: GameExecJudge(); break;
		case GAME_EXEC_OVER:  GameExecOver();  break;

		default:
			break;
	}

//	OledDrawStr(0, 4, "%03d %x", FrameGetCpuPercentMax(), FrameGetCnt());
}


void main() {

int s;
    
clear_screen();
screen_setup(SCREEN,2730);
create_tbl();
RndInit();
_memset(&Game, 0x00, sizeof(ST_GAME));

            lcdPrintText("TINY", 40, 0);//OledDrawStr( 0, 0, "TINY");
	    lcdPrintText("2048", 40, 8);//OledDrawStr( 0, 1, "2048");
            lcdPrintText("Автор Akkera", 9, 16);//OledDrawStr( 0, 1, "2048");
            lcdPrintText("Портировал", 18, 24); //OledDrawStr(17, 2, "BEST");  
            lcdPrintText("Ведущий", 26, 32); //OledDrawStr(17, 2, "BEST");  
            lcdPrintText("Специалист", 18, 40); //OledDrawStr(17, 2, "BEST");  
            lcdPrintText("Начало - ввод", 7, 48);
while(GetInput()!=KEY_enter);
	
         clear_screen();
         draw_main_screen();
  while(1) 
  {
   GameLoop();
   
  // DrawInt(Rnd32(),50, 50);
   //s++;
 
  }
}

