#ifndef __MAIN_H
#define __MAIN_H

#define VIDEO_BPL 78
//#define uint8_t unsigned char
#define bool char
#define true 1
#define false 0
#define uint8_t  unsigned char
#define uchar  unsigned char
#define uint16_t unsigned int
#define uint unsigned int
#define int32_t  long
#define nullptr  0
#define int8_t   char
#define int16_t  int

#define u32 unsigned long
#define s32 signed long

#define TRUE 1
#define FALSE 0
#define uint32_t unsigned long
#define u8 unsigned char
#define s16 signed int
#define s8 signed char


enum {
	GAME_EXEC_RESET,
	GAME_EXEC_ANIME,
	GAME_EXEC_PLAY,
	GAME_EXEC_JUDGE,
	GAME_EXEC_OVER,
};

typedef struct {
	u8 act;

} ST_GAME;


#define SCREEN 0x6b50

#define KEY_enter    251
#define KEY_space    127 //
#define KEY_left     239
#define KEY_right    191
#define KEY_up       223
#define KEY_down     127

#define KEY_U 1 // fix
#define KEY_D 2
#define KEY_L 3
#define KEY_R 4 // end fix


#define NUM2FIX(N)				((N) << 8)
#define FIX2NUM(F)				((F) >> 8)


void put_text(uint8_t* a,uint8_t x,uint8_t y, uint8_t* text);
uint8_t lcdPrintText(char const *ptrText, uint8_t x, uint8_t y);
void clear_chargen_ram(void);
void create_tbl(void);
void cleardot(void);
void drawdot(void);
void LCD_Rect(int xPos, uint8_t yPos, int width, uint8_t height, unsigned char filled);
void LCD_HLine(int xPos, int yPos, int width);
void lcd_line(uchar x0, uchar x1, uchar y0, uchar y1, uint8_t color);
void fillRect(void);
void clear_screen(void);
void screen_setup(uint video_mem,uint length);
#define FONT_WIDTH 4
#define FONT_HEIGHT 6
void DrawInt(int16_t val, uint8_t x, uint8_t y);
void GameSetAct(u8 act);
uint8_t GetInput();
void _memset(void* s, u8 c, s16 size);
void panel_clear(void);
#endif 