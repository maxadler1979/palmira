#include "score.h"
#include "rnd.h"
#include "main.h"

extern void _memset(void* s, u8 c, s16 size);
//---------------------------------------------------------------------------
ST_SCORE Score;


//---------------------------------------------------------------------------
void ScoreInit(void)
{
	_memset(&Score, 0x00, sizeof(ST_SCORE));

	ScoreInitRnd();
	ScoreLoadBest();
}
//---------------------------------------------------------------------------
void ScoreInitRnd(void)
{
	//EepSeek(0x10);
	//u32 r = EepRead32();
        u32 r;
	if(r != 0)
	{
	 RndInitSeed(r);
	}

	//EepSeek(0x10);
	//EepWrite32(Rnd32());
}
//---------------------------------------------------------------------------
void ScoreDraw(void)
{
	DrawInt(Score.now,97, 8); //OledDrawStr(16, 1, "%5d", Score.now);
	//DrawInt(Score.best,97,24); //OledDrawStr(16, 3, "%5d", Score.best);
}
//---------------------------------------------------------------------------
void ScoreSaveBest(void)
{
	if(Score.best > Score.now)
	{
		return;
	}
	Score.best = Score.now;

/*
	EepSeek(0);
	EepWrite8('2');
	EepWrite8('0');
	EepWrite8('4');
	EepWrite8('8');

	EepWrite16(Score.best);
*/
}
//---------------------------------------------------------------------------
void ScoreLoadBest(void)
{
	Score.best = 0;

/*
	EepSeek(0);

	if(EepRead8() != '2') return;
	if(EepRead8() != '0') return;
	if(EepRead8() != '4') return;
	if(EepRead8() != '8') return;
*/
	Score.best = 0;//EepRead16();
}
//---------------------------------------------------------------------------
void ScoreAddNow(u8 num)
{
	if(num >= 10)
	{
		Score.is10 = TRUE;
	}

	Score.now += num;
}
//---------------------------------------------------------------------------
bool ScoreIs10(void)
{
	return Score.is10;
}
//---------------------------------------------------------------------------
void ScoreDebug(void)
{
	//EepSeek(0);
	//EepWrite16(0);

	//EepSeek(0x10);
	//EepWrite32(0);
}
