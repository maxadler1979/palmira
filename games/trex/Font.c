// Compact font taken from
// https://hackaday.io/project/6309-vga-graphics-over-spi-and-serial-vgatonic/log/20759-a-tiny-4x6-pixel-font-that-will-fit-on-almost-any-microcontroller-license-mit

#include "main.h"
#include "Font.h"


// Font Definition
const uint8_t font4x6[96][2] = {
	{ 0x00  ,  0x00 },   /*SPACE*/
	{ 0x49  ,  0x08 },   /*'!'*/
	{ 0xb4  ,  0x00 },   /*'"'*/
	{ 0xbe  ,  0xf6 },   /*'#'*/
	{ 0x7b  ,  0x7a },   /*'$'*/
	{ 0xa5  ,  0x94 },   /*'%'*/
	{ 0x55  ,  0xb8 },   /*'&'*/
	{ 0x48  ,  0x00 },   /*'''*/
	{ 0x29  ,  0x44 },   /*'('*/
	{ 0x44  ,  0x2a },   /*')'*/
	{ 0x15  ,  0xa0 },   /*'*'*/
	{ 0x0b  ,  0x42 },   /*'+'*/
	{ 0x00  ,  0x50 },   /*','*/
	{ 0x03  ,  0x02 },   /*'-'*/
	{ 0x00  ,  0x08 },   /*'.'*/
	{ 0x25  ,  0x90 },   /*'/'*/
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
	{ 0x08  ,  0x40 },   /*':'*/
	{ 0x08  ,  0x50 },   /*';'*/
	{ 0x2a  ,  0x44 },   /*'<'*/
	{ 0x1c  ,  0xe0 },   /*'='*/
	{ 0x88  ,  0x52 },   /*'>'*/
	{ 0xe5  ,  0x08 },   /*'?'*/
	{ 0x56  ,  0x8e },   /*'@'*/
	{ 0x77  ,  0xb6 },   /*'A'*/
	{ 0x77  ,  0xb8 },   /*'B'*/
	{ 0x72  ,  0x8c },   /*'C'*/
	{ 0xd6  ,  0xba },   /*'D'*/
	{ 0x73  ,  0x9e },   /*'E'*/
	{ 0x73  ,  0x92 },   /*'F'*/
	{ 0x72  ,  0xae },   /*'G'*/
	{ 0xb7  ,  0xb6 },   /*'H'*/
	{ 0xe9  ,  0x5c },   /*'I'*/
	{ 0x64  ,  0xaa },   /*'J'*/
	{ 0xb7  ,  0xb4 },   /*'K'*/
	{ 0x92  ,  0x9c },   /*'L'*/
	{ 0xbe  ,  0xb6 },   /*'M'*/
	{ 0xd6  ,  0xb6 },   /*'N'*/
	{ 0x56  ,  0xaa },   /*'O'*/
	{ 0xd7  ,  0x92 },   /*'P'*/
	{ 0x76  ,  0xee },   /*'Q'*/
	{ 0x77  ,  0xb4 },   /*'R'*/
	{ 0x71  ,  0x38 },   /*'S'*/
	{ 0xe9  ,  0x48 },   /*'T'*/
	{ 0xb6  ,  0xae },   /*'U'*/
	{ 0xb6  ,  0xaa },   /*'V'*/
	{ 0xb6  ,  0xf6 },   /*'W'*/
	{ 0xb5  ,  0xb4 },   /*'X'*/
	{ 0xb5  ,  0x48 },   /*'Y'*/
	{ 0xe5  ,  0x9c },   /*'Z'*/
	{ 0x69  ,  0x4c },   /*'['*/
	{ 0x91  ,  0x24 },   /*'\'*/
	{ 0x64  ,  0x2e },   /*']'*/
	{ 0x54  ,  0x00 },   /*'^'*/
	{ 0x00  ,  0x1c },   /*'_'*/
	{ 0x44  ,  0x00 },   /*'`'*/
	{ 0x0e  ,  0xae },   /*'a'*/
	{ 0x9a  ,  0xba },   /*'b'*/
	{ 0x0e  ,  0x8c },   /*'c'*/
	{ 0x2e  ,  0xae },   /*'d'*/
	{ 0x0e  ,  0xce },   /*'e'*/
	{ 0x56  ,  0xd0 },   /*'f'*/
	{ 0x55  ,  0x3B },   /*'g'*/
	{ 0x93  ,  0xb4 },   /*'h'*/
	{ 0x41  ,  0x44 },   /*'i'*/
	{ 0x41  ,  0x51 },   /*'j'*/
	{ 0x97  ,  0xb4 },   /*'k'*/
	{ 0x49  ,  0x44 },   /*'l'*/
	{ 0x17  ,  0xb6 },   /*'m'*/
	{ 0x1a  ,  0xb6 },   /*'n'*/
	{ 0x0a  ,  0xaa },   /*'o'*/
	{ 0xd6  ,  0xd3 },   /*'p'*/
	{ 0x76  ,  0x67 },   /*'q'*/
	{ 0x17  ,  0x90 },   /*'r'*/
	{ 0x0f  ,  0x38 },   /*'s'*/
	{ 0x9a  ,  0x8c },   /*'t'*/
	{ 0x16  ,  0xae },   /*'u'*/
	{ 0x16  ,  0xba },   /*'v'*/
	{ 0x16  ,  0xf6 },   /*'w'*/
	{ 0x15  ,  0xb4 },   /*'x'*/
	{ 0xb5  ,  0x2b },   /*'y'*/
	{ 0x1c  ,  0x5e },   /*'z'*/
	{ 0x6b  ,  0x4c },   /*'{'*/
	{ 0x49  ,  0x48 },   /*'|'*/
	{ 0xc9  ,  0x5a },   /*'}'*/
	{ 0x54  ,  0x00 },   /*'~'*/
	{ 0x56  ,  0xe2 }    /*''*/
};




static uint8_t PrintX, PrintY;

void DrawChar(char c)
{
	const uint8_t index = ((unsigned char)(c)) - 32;
	uint8_t data1 = pgm_read_byte(&font4x6[index][0]);
	uint8_t data2 = pgm_read_byte(&font4x6[index][1]);
	uint8_t y = PrintY;

	if (data2 & 1)	// Descender e.g. j, g
	{
		drawdot(PrintX, y, 1);
		drawdot(PrintX + 1, y, 1);
		drawdot(PrintX + 2, y, 1);
		drawdot(PrintX + 3, y, 1);
		y++;

		drawdot(PrintX, y, (data1 & 0x80) ? 0 : 1);
		drawdot(PrintX + 1, y, (data1 & 0x40) ? 0 : 1);
		drawdot(PrintX + 2, y, (data1 & 0x20) ? 0 : 1);
		drawdot(PrintX + 3, y, 1);
		y++;

		drawdot(PrintX, y, (data1 & 0x10) ? 0 : 1);
		drawdot(PrintX + 1, y, (data1 & 0x8) ? 0 : 1);
		drawdot(PrintX + 2, y, (data1 & 0x4) ? 0 : 1);
		drawdot(PrintX + 3, y, 1);
		y++;

		drawdot(PrintX, y, (data1 & 0x2) ? 0 : 1);
		drawdot(PrintX + 1, y, (data1 & 0x1) ? 0 : 1);
		drawdot(PrintX + 2, y, (data2 & 0x2) ? 0 : 1);
		drawdot(PrintX + 3, y, 1);
		y++;

		drawdot(PrintX, y, (data2 & 0x80) ? 0 : 1);
		drawdot(PrintX + 1, y, (data2 & 0x40) ? 0 : 1);
		drawdot(PrintX + 2, y, (data2 & 0x20) ? 0 : 1);
		drawdot(PrintX + 3, y, 1);
		y++;

		drawdot(PrintX, y, (data2 & 0x10) ? 0 : 1);
		drawdot(PrintX + 1, y, (data2 & 0x8) ? 0 : 1);
		drawdot(PrintX + 2, y, (data2 & 0x4) ? 0 : 1);
		drawdot(PrintX + 3, y, 1);
		y++;
	}
	else
	{
		drawdot(PrintX, y, (data1 & 0x80) ? 0 : 1);
		drawdot(PrintX + 1, y, (data1 & 0x40) ? 0 : 1);
		drawdot(PrintX + 2, y, (data1 & 0x20) ? 0 : 1);
		drawdot(PrintX + 3, y, 1);
		y++;

		drawdot(PrintX, y, (data1 & 0x10) ? 0 : 1);
		drawdot(PrintX + 1, y, (data1 & 0x8) ? 0 : 1);
		drawdot(PrintX + 2, y, (data1 & 0x4) ? 0 : 1);
		drawdot(PrintX + 3, y, 1);
		y++;

		drawdot(PrintX, y, (data1 & 0x2) ? 0 : 1);
		drawdot(PrintX + 1, y, (data1 & 0x1) ? 0 : 1);
		drawdot(PrintX + 2, y, (data2 & 0x2) ? 0 : 1);
		drawdot(PrintX + 3, y, 1);
		y++;

		drawdot(PrintX, y, (data2 & 0x80) ? 0 : 1);
		drawdot(PrintX + 1, y, (data2 & 0x40) ? 0 : 1);
		drawdot(PrintX + 2, y, (data2 & 0x20) ? 0 : 1);
		drawdot(PrintX + 3, y, 1);
		y++;

		drawdot(PrintX, y, (data2 & 0x10) ? 0 : 1);
		drawdot(PrintX + 1, y, (data2 & 0x8) ? 0 : 1);
		drawdot(PrintX + 2, y, (data2 & 0x4) ? 0 : 1);
		drawdot(PrintX + 3, y, 1);
		y++;

		drawdot(PrintX, y, 1);
		drawdot(PrintX + 1, y, 1);
		drawdot(PrintX + 2, y, 1);
		drawdot(PrintX + 3, y, 1);
	}
}

void DrawString(const char* str, uint8_t x, uint8_t y)
{
	PrintX = x;
	PrintY = y;

	for (;;)
	{
		char c = pgm_read_byte(str++);
		if (!c)
			break;

		DrawChar(c);
		PrintX += FONT_WIDTH;
	}
}



void cleardot(char x,char y) //6 4
{
	#asm
        ld hl,4; y
        add hl,sp
        ld c,(hl) ; ��������� Y � B
     
         ld hl,6; x
        add hl,sp
        ld b,(hl) ; ��������� X � C
        ;lhld _coordata
       ; mov b,l;
        ;mov c,h
	
	#endasm
}


void drawdot(char x,char y,char vis)
{
	#asm
         ld hl,4; y
         add hl,sp
         ld c,(hl) ; ��������� Y � B
     
         ld hl,6; x
         add hl,sp
         ld b,(hl) ; ��������� X � C

         ld hl,2; vis
         add hl,sp
         ld a,(hl) ;
         cpi 0
         jnz to_draw
        
        CALL GETDOT
	CMA
	ANA M
	MOV M,A
	RET
to_draw:
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
	MVI H,69h
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

VADDR: 
defw 0x6a00  //��� ����� �����������

VISIONS:
defb 1,2,16,4
	#endasm
}
