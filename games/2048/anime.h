#include "main.h"


#define ANIME_MAX_DATA_CNT				24


enum {
	ANIME_TYPE_MAKE,
	ANIME_TYPE_MOVE,
	ANIME_TYPE_DISP,
	ANIME_TYPE_ADD,
};

//---------------------------------------------------------------------------




//---------------------------------------------------------------------------
void AnimeInit(void);
void AnimeReset(void);

void AnimeExec(void);
void AnimeExecMake(u8 num);
void AnimeExecMove(u8 num);
void AnimeExecDisp(u8 num);
void AnimeExecAdd(u8 num);

void AnimeSetMake(s8 sx, s8 sy, u8 num);
void AnimeSetMove(s8 sx, s8 sy, s8 dx, s8 dy, u8 num, u8 dir);
void AnimeSetDisp(s8 sx, s8 sy, u8 num);
void AnimeSetAdd(s8 sx, s8 sy, u8 num);

bool AnimeIsAdd(s8 x, s8 y);
bool AnimeIsEnd(void);
bool AnimeIsDispOnly(void);
