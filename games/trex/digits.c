#include <stdint.h>
#include "main.h"

char i_a=0;
char i_b=0;
char i_c=0;
char i_d=0;

extern uint8_t* put_sprite_3;

unsigned char zero[8] = {3,2,
	0x12, 0x11, 0x11, 0x11, 0x03, 0x00
};
unsigned char one[8] = {3,2,
	0x04, 0x11, 0x00, 0x11, 0x00, 0x01
};
unsigned char two[8] = {3,2,
	0x03, 0x11, 0x12, 0x01, 0x03, 0x01
};
unsigned char free[8] = {3,2,
	0x03, 0x11, 0x02, 0x10, 0x03, 0x00
};
unsigned char four[8] = {3,2,
	0x11, 0x11, 0x03, 0x11, 0x00, 0x01
};
unsigned char five[8] = {3,2,
	0x13, 0x01, 0x02, 0x11, 0x03, 0x01
};
unsigned char six[8] = {3,2,
	0x12, 0x01, 0x13, 0x11, 0x03, 0x00
};
unsigned char seven[8] = {3,2,
	0x03, 0x11,
        0x06, 0x00,
        0x02, 0x00
};
unsigned char vosem[8] = {3,2,
	0x12, 0x11,
        0x13, 0x11,
        0x03, 0x00
};
unsigned char nine[8] = {3,2,
	0x12, 0x11,
        0x03, 0x11,
        0x03, 0x00
};

unsigned char *Digits[] =
{
  zero,one,two,free,four,five,six,seven,vosem,nine,
 
};




void inc_score(void)
{
#asm
  lda _i_d; // �������
  inr a     // ���������� 1
  cpi 10 // ==10?
  jz a1     // ������� � �1
  sta _i_d  //!=10, ��������� � �������
  ret
a1:
  mvi a,0 //����� � ������� 0, ���������
  sta _i_d

  lda _i_c //��������� �������
  inr a  // ���������� �������
  cpi 10 // ���� ==10
  jz a2     // ����� �� ����������� �����
  sta _i_c  // � ��� �������� � ������
  ret
a2:
  mvi a,0 //����� � ������� 0, ���������
  sta _i_c 
 
  lda _i_b   //��������� �����
  inr a      // ���������� �����
  cpi 10  // ���� ==10
  jz a3      // ����� �� ����������� �����
  sta _i_b  // � ��� �������� � ������
  ret
a3:
  mvi a,0 //����� � ������� 0, ���������
  sta _i_b 
 
  lda _i_a   //��������� ������
  inr a      // ���������� ������
  cpi 10  // ���� ==10
  jz a4      // ����� �� ����������� � �����
  sta _i_a  // � ��� �������� � ������
    ret

a4:  
     mvi a,9
     sta _i_a
ret
 



#endasm
}

void DrawScore(uint8_t x, uint8_t y)
{

 
	put_sprite_3 = Digits[i_a];// ������
        put_sprite(x,y);
        x+=2;
        put_sprite_3 = Digits[i_b];// �����
        put_sprite(x,y);
        x+=2;
        put_sprite_3 = Digits[i_c];// �������
        put_sprite(x,y);
        x+=2;
        put_sprite_3 = Digits[i_d];// �������
        put_sprite(x,y);
   		

	
}

void DrawUInt(uint16_t val, uint8_t x, uint8_t y)
{
        unsigned char c;
	for (char n = 0; n < 6 && val != 0; n++)
	{
		c= val % 10;
		put_sprite_3 = Digits[c];//
                put_sprite(x,y);
                x-=2;
		val = val / 10;
	}
}