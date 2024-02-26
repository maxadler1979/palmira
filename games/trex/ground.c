#include "ground.h"
#include "main.h"
#define ground_y 26
uint8_t bgx=14;
uint8_t xts;

uint8_t level_tiles=0;
extern uint8_t* put_sprite_3;
uint8_t ground_mass[30] = {
0,0,1,2,3,
4,4,5,4,3,
0,2,4,2,1,
5,2,4,3,0,
0,0,1,2,3,
0,0,1,2,3};
extern unsigned char ground1[];
extern unsigned char ground2[];
extern unsigned char ground3[];
/*
void paus(void)
{
int i=150;
while(i>0)
{
i--;
}
}
*/

void scroll(void)
{
char t=0;

 xts = 1;  
 put_sprite_3 = TileMap[ground_mass[level_tiles]]+((14-bgx)*6);;
 put_tile(xts,ground_y,bgx);// отрисуем крайний левый  тайл земли
 xts+=bgx;
 for(t=1;t<5;t++)
{
 put_sprite_3 = TileMap[ground_mass[t+level_tiles]];
 put_tile(xts,ground_y,14); //отрисуем землю 1
 xts=xts+14;
}

 put_sprite_3 = TileMap[ground_mass[level_tiles+5]];
 put_tile(xts,ground_y,14-bgx);// отрисуем крайний правый  тайл земли
 //paus();
 bgx-=2;
 if (bgx==0) { // если отрисован весь тайл - начнем выводить его заново считаем из массива следующий тайл
 level_tiles++;
 if (level_tiles==25)level_tiles = 0;
 bgx=14;}
}
