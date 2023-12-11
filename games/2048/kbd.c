#include "main.h"


uchar* vv55 = (uchar*)0x8000;



uchar key_scan(uchar row) // возвращает код нажатой клавиши
{
	uchar z = 0;
	vv55[0] = row;
	return vv55[1];
}

 uint8_t GetInput()
{
 //uint8_t result = 0;
 uint8_t kb;
 kb=0xff;

//dig=key_scan(0xfb);//fb - 1(253)2(251)3(247)4(239)5(223)6(191)7(127)
//DrawInt(kb, 17, 1);
//return result;



 kb=key_scan(0x7e); //7e = f1 f2 f3 f4 f5 space y z x
 
  
  if (kb==127) //space
    {
        return KEY_space;
    }

 kb=key_scan(0xfd);
   if (kb==251)
    {
       return KEY_enter;
    }

   if (kb==223)
    {
      
        return KEY_up;
    }
   if (kb==127)
    {
       return KEY_down;
    }
   if (kb==239)
    {
      return KEY_left;
    }
   if (kb==191)
    {
        return KEY_right;
    }
  

// 0xfd left 239 rifht 191 up 223 down 127 enter 251
// ul 207 ur 159 dl 111 dr 63 
//7e space 127 

 //DrawInt(kb, 17, 1);
return kb;

}
