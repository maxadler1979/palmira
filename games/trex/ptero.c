#include "main.h"
#include "ptero.h"

char ptero_enable;
extern uint8_t* put_sprite_3;
extern uint8_t end;
extern char cactus_enable;
extern char i_a;
pterodactyl_t ptero;

void ptero_init(void)
{
 ptero.live = 0; 
 ptero_enable = 0;
 ptero.y = 22;
 ptero.AnimFrame = 0;
 //ptero_enable = 1;
}

void ptero_check(void) //породим новый кактус
{
    if (ptero.live > 0) return;
    if (ptero_enable == 0) return; 

if (random(1, 55)==20) // рандомно сгенерим новый кактус в зависимости от уровня
   {
    ptero_enable = 0;
    ptero.live = 1; // птеродактиль на экран
    ptero.x = 70; 
    if (random(1, 15)>=10) // рандомно сгенерим новый кактус в зависимости от уровня
    {
     ptero.y = 20;
    }
    else
    {
    ptero.y = 13;
    }
    ptero.AnimRow = 0; // начнем вывод с 1 столбца
    ptero.ptero_ptr = Ptero[1];
   }
}

void ptero_core(void)
{

    if (ptero.live > 0){


if (ptero.x>4) {
put_sprite_3 = Ptero[ptero.AnimFrame];
put_ptero(ptero.x,ptero.y, ptero.AnimRow);

check_ptero_collision(ptero.x,ptero.y);
if (i_a>=1) ptero.x-=2; else ptero.x--;
if (ptero.x <30) cactus_enable=1; else cactus_enable=0;
if (ptero.AnimRow<12) 
    {
     if (i_a<1) ptero.AnimRow++;else ptero.AnimRow+=2;
    }
}
else
{
ptero.x = 4;
put_sprite_3 = Ptero[ptero.AnimFrame]+((12-ptero.AnimRow)*8);
put_ptero(ptero.x,ptero.y, ptero.AnimRow);
ptero.AnimRow--;
if (ptero.AnimRow == 0)
 {
 ptero.live = 0;
 }

}
ptero.time_to_next_sprite++;
             if (ptero.time_to_next_sprite==6)
             {
             if (ptero.AnimFrame==0) ptero.AnimFrame = 1; else ptero.AnimFrame = 0; // шевелим ногами (меняем спрайты)
             ptero.time_to_next_sprite=0;
             }
}
}