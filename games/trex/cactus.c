#include "cactus.h"
#include "main.h"
cactus_t cactus;
char cactus_enable;

extern uint8_t* put_sprite_3;
extern uint8_t end;
extern char ptero_enable;
extern char i_a;
void paus(void)
{
int i=50;
while(i>0)
{
i--;
}
}


uint8_t cactus_dim[5] = {14,11,11,13};

void cactus_init(void)
{
 cactus.show = 0;
 cactus_enable = 1;
}

void cactus_check(void) //породим новый кактус
{
    if (cactus.show   == 1) return; 
    if (cactus_enable == 0) return; 

if (random(1, 105)==25) // рандомно сгенерим новый кактус в зависимости от уровня
   {
    cactus_enable=0;
    cactus.type = random(0, 3);
    cactus.dimension = cactus_dim[cactus.type];
    cactus.show = 1; // кактус на экран
    cactus.cactus_ptr = Cactus[cactus.type]; //начало анимации 
    cactus.x = 70; 
    cactus.AnimRow = 1; // начнем вывод с 1 столбца
   }
}

void cactus_core(void)
{

    if (cactus.show > 0){
//paus();
if (i_a>=1){ // очки за 1000 и птеро летит быстро
 if (cactus.x<20) ptero_enable = 1; else ptero_enable = 0;// отодвинем кактус еще левее прежде чем разрешить полететь птеродактилю
}
else
{
 if (cactus.x<30) ptero_enable = 1; else ptero_enable = 0;
}
if (cactus.x>4) {
put_sprite_3 = cactus.cactus_ptr;
put_cactus(cactus.x,19, cactus.AnimRow);
check_cactus_collision(cactus.x);
cactus.x--;
if (cactus.AnimRow<=cactus.dimension-1) cactus.AnimRow++;//cactus.AnimRow=12;
}
else
{
cactus.x = 4;
put_sprite_3 = cactus.cactus_ptr+(((cactus.dimension)-cactus.AnimRow)*10);
put_cactus(cactus.x,19, cactus.AnimRow);
cactus.AnimRow--;
if (cactus.AnimRow == 0)
 {
 cactus.show = 0;
 }

}



}

}