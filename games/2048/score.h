

#define u16 unsigned int
#define bool char
#define u8 unsigned char
//---------------------------------------------------------------------------

typedef struct {
	u16  now;
	u16  best;
	bool is10;

} ST_SCORE;


//---------------------------------------------------------------------------
void ScoreInit(void);
void ScoreInitRnd(void);
void ScoreDraw(void);

void ScoreSaveBest(void);
void ScoreLoadBest(void);

void ScoreAddNow(u8 num);
bool ScoreIs10(void);
void ScoreDebug(void);

