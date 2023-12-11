#include <string.h>
#include "fonts.h"
#include "main.h"
extern unsigned char coordata[2];
static uint8_t PrintX, PrintY;

uchar* VG75 = (uchar*)0xC000;
uchar* VT57 = (uchar*)0xE000;

uchar put_sprite_1;//x
uchar put_sprite_2;//y
char* put_sprite_3;//bmp

uchar* pr_dest;
uchar pr_len;
uchar* pr_text;

uchar* radio86rkVideoMem = (uchar*)(SCREEN + 78*3 + 8);
uchar  radio86rkVideoBpl = 78;
unsigned char coordata[2];
/*
lcd_line(1, 127, 1, 63, 1);
LCD_HLine(1, 0, 127);
LCD_HLine(1, 63, 127);
lcdPrintText("simsave1.sav", 1, 2);
*/

void waitHorzSync() {
 #asm
    lxi h,0c001h
    mov a,m
waitHorzSync_1:
    mov a, m
    ani 20h
    jz waitHorzSync_1
  #endasm
}




void screen_setup(uint video_mem,uint length)
{
  VG75[1] = 0; //
  VG75[0] = 0x4d; //
  VG75[0] = 0x22; //
  VG75[0] = 0x17; //7e
  VG75[0] = 0x53; //
  VG75[1] = 0x23; //
  while((VG75[1] & 0x20) == 0); //
  while((VG75[1] & 0x20) == 0); //
  VT57[8] = 0x80; //
  VT57[4] = (uchar)(video_mem); //
  VT57[4] = (uchar)((video_mem)>>8); //
  VT57[5] = (uchar)((length)-1); //
  VT57[5] = 0x40 | (uchar)(((length)-1)>>8); //
  VT57[8] = 0xA4; //	
}


void delay(int z)
{
  while(z--);
}
uchar* fr_a;
uchar fr_w;
uchar fr_h;
uchar fr_c;
void clear_screen(void)
{
 fr_a = (uchar*)0x6b50; //start address 
 fr_w = 78; // weight rect w - fillRect_2
 fr_h = 36; // height rect h - fillRect_3
 fr_c = 0; //; code to fill c - fillRect_4
 fillRect();
}




void SetPixel(int x, int y,uint8_t color){
  coordata[0]=x;
  coordata[1]=y;
  if (color)
{
  
 drawdot();
}
else
{

 cleardot(); 
}
  
}

void lcd_line(uchar x0, uchar x1, uchar y0, uchar y1, uint8_t color){
    
    int dy, dx, fraction;
    int stepx, stepy;
    dy = y1 - y0;
    dx = x1 - x0;
    if(dy < 0){
        dy = -dy;
        stepy = -1;
    } else{
        stepy = 1;
    }
    if(dx < 0){
        dx = -dx;
        stepx = -1;
    } else{
        stepx = 1;
    }
    dy <<= 1;
    dx <<= 1;

    SetPixel(x0, y0,color);
    if(dx > dy){
        fraction = dy - (dx >> 1);
        while(x0 != x1){
            if(fraction >= 0){
                y0 += stepy;
                fraction -= dx;
            }
            x0 += stepx;
            fraction += dy;
            SetPixel(x0, y0,color);
        }
    } else{
        fraction = dx - (dy >> 1);
        while(y0 != y1){
            if(fraction >= 0){
                x0 += stepx;
                fraction -= dy;
            }
            y0 += stepy;
            fraction += dx;
            SetPixel(x0, y0,color);
        }
    }
}

void LCD_HLine(int xPos, int yPos, int width){
    SetPixel(xPos + width - 1, yPos,1);
    SetPixel(xPos, yPos,1);
    while(width){
        SetPixel(xPos, yPos,1);
        xPos++;
        width--;
    }
}
//-----

void LCD_Rect(int xPos, uint8_t yPos, int width, uint8_t height, unsigned char filled){
    unsigned int y;
    LCD_HLine(xPos, yPos, width);
    LCD_HLine(xPos, yPos + height - 1, width);

    if(filled == 1){
        for(y = 1; y < height; y++){
            LCD_HLine(xPos, yPos + y, width);
        }
    } else{
        for(y = 1; y < height; y++){
            SetPixel(xPos, yPos + y,1);
            SetPixel(xPos + width - 1, yPos + y,1);
        }
    }
}

void put_char(uint8_t x, uint8_t y, uint8_t chr){
    unsigned char h, ch, p, mask;
    char xx, yy;
    xx = x;
    yy = y;
    
     for(h = 0; h < 8; h++) // каждая строка символа (байт)
    {
      if(chr < 0xc0){
               ch = font_8x8[ chr - 32 ][h];
            } else{
                ch = font_8x8[ chr - 96 ][h];
            }
       
        mask = 0x80;
        xx = x;
         for(p = 0; p < 8; p++) //отрисовываем пикселы строки символа
        {
             SetPixel(xx, yy,ch & mask);  //SetPixel(xx, yy); // 
             mask = mask >>1;
             xx++;
        }
        yy++;
    }
}

uint8_t lcdPrintText(char const *ptrText, uint8_t x, uint8_t y){
    
for(; *ptrText; ptrText++){
            put_char(x, y, *ptrText);
             x += 8;
           
        }
    return x;
}

#define pgm_read_byte(x) (*((uint8_t*)x))

// Font Definition
const uint8_t font4x6[10][2] = {

	{ 0x76  ,  0xba },   /*'0'*/
	{ 0x59  ,  0x5c },   /*'1'*/
	{ 0xc5  ,  0x9e },   /*'2'*/
	{ 0xc5  ,  0x38 },   /*'3'*/
	{ 0x92  ,  0xe6 },   /*'4'*/
	{ 0xf3  ,  0x3a },   /*'5'*/
	{ 0x73  ,  0xba },   /*'6'*/
	{ 0xe5  ,  0x90 },   /*'7'*/
	{ 0x77  ,  0xba },   /*'8'*/
	{ 0x77  ,  0x3a },   /*'9'*/

};



void DrawChar(char c)
{
	const uint8_t index = ((unsigned char)(c)) - 48;
	uint8_t data1 = pgm_read_byte(&font4x6[index][0]);
	uint8_t data2 = pgm_read_byte(&font4x6[index][1]);
	uint8_t y = PrintY;

	

		SetPixel(PrintX, y, (data1 & 0x80) ? 1 : 0);
		SetPixel(PrintX + 1, y, (data1 & 0x40) ? 1 : 0);
		SetPixel(PrintX + 2, y, (data1 & 0x20) ? 1 : 0);
		//SetPixel(PrintX + 3, y, 1);
		y++;

		SetPixel(PrintX, y, (data1 & 0x10) ? 1 : 0);
		SetPixel(PrintX + 1, y, (data1 & 0x8) ? 1 : 0);
		SetPixel(PrintX + 2, y, (data1 & 0x4) ? 1 : 0);
		//SetPixel(PrintX + 3, y, 1);
		y++;

		SetPixel(PrintX, y, (data1 & 0x2) ? 1 : 0);
		SetPixel(PrintX + 1, y, (data1 & 0x1) ? 1 : 0);
		SetPixel(PrintX + 2, y, (data2 & 0x2) ? 1 : 0);
		//SetPixel(PrintX + 3, y, 1);
		y++;

		SetPixel(PrintX, y, (data2 & 0x80) ? 1 : 0);
		SetPixel(PrintX + 1, y, (data2 & 0x40) ? 1 : 0);
		SetPixel(PrintX + 2, y, (data2 & 0x20) ? 1 : 0);
		//SetPixel(PrintX + 3, y, 1);
		y++;

		SetPixel(PrintX, y, (data2 & 0x10) ? 1 : 0);
		SetPixel(PrintX + 1, y, (data2 & 0x8) ? 1 : 0);
		SetPixel(PrintX + 2, y, (data2 & 0x4) ? 1 : 0);
		//SetPixel(PrintX + 3, y, 1);
		


		
}

#define MAX_DIGITS 5
void DrawInt(int16_t val, uint8_t x, uint8_t y)
{
	PrintX = x;
	PrintY = y;

	if (val == 0)
	{
		DrawChar('0');
		return;
	}
	else if (val < 0)
	{
		DrawChar('-');
		PrintX += FONT_WIDTH;
	}

	char buffer[MAX_DIGITS];
	int bufCount = 0;

	for (int n = 0; n < MAX_DIGITS && val != 0; n++)
	{
		unsigned char c = val % 10;
		buffer[bufCount++] = '0' + c;
		val = val / 10;
	}

	for (int n = bufCount - 1; n >= 0; n--)
	{
		DrawChar(buffer[n]);
		PrintX += FONT_WIDTH;
	}
}


