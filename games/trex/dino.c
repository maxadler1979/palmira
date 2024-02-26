

#include "dino.h"
//#include "cactus.h"
#include "main.h"

#define right_x 40
#define left_x 5

extern uint8_t* put_sprite_3;
extern unsigned  char dino_empty[];
extern uint8_t end;
dino_t dino;

unsigned char dino_jump[9] = {16,12,11,8,8,8,14,16,18};
unsigned char di_jmp_dl[9] = { 1, 2, 2,3,7,5, 3, 2, 1};
unsigned char dino_jump_pointer = 0;
uint8_t dino_duck_delay = 0;
uint8_t jump_delay;

void dino_init(void)
{
 dino.dino_ptr = Dino[1];
 dino.x = 10;
 dino.y = 18;
 dino.AnimFrame = 0;
 dino.jump =0;
 dino.duck =0; 
 dino.busy =0;
 dino_jump_pointer = 0;
}

void check_cactus_collision(uint8_t x_cactus)
{
// проверим на столкновение с кактусом

 
if (dino.x+5 >= x_cactus) 
    {
    if (dino.x+5<= x_cactus+13)
        {
         if (dino.y>=12) {
            end = 1;
             dino.dino_ptr = Dino[3]; //Dino_died
            }
        }
    
    }


}
void check_ptero_collision(uint8_t x_ptero,uint8_t y_ptero)
{
// проверим на столкновение с кактусом
 
 
if (dino.x+5 >= x_ptero) 
    {
    if (dino.x+5<= x_ptero+9)
        {
         if (y_ptero == 20){// летит внизу
                if (dino.y>=12) {
                end = 1;
                dino.dino_ptr = Dino[3]; //Dino_died
               
                }
            }
         if (y_ptero == 13){// летит вверху
                if (dino.duck!=1) {
                end = 1;
                dino.dino_ptr = Dino[3]; //Dino_died
 
                }
            }
                put_sprite_3 = dino.dino_ptr[dino.AnimFrame];
                put_sprite(dino.x,dino.y);   
        }
    
    }


}

void dino_core(void)
{
 

  if (dino.jump !=1) // если не прыгаем
{           
             put_sprite_3 = dino.dino_ptr[dino.AnimFrame]; // отрисуем текущий спрайт
             put_sprite(dino.x,dino.y); // выведем по координатам
             dino.AnimFrame_delay++;
             if (dino.AnimFrame_delay==2)
             {
             if (dino.AnimFrame==0) dino.AnimFrame = 1; else dino.AnimFrame = 0; // шевелим ногами (меняем спрайты)
             dino.AnimFrame_delay=0;
             }

            if (dino.duck==1)
            {
                if (dino_duck_delay ==20)
                {
                 put_sprite_3 = dino_empty;// пустой спрайт
                 put_sprite(dino.x,18);
                }
             dino_duck_delay --;
            // end = check_cactus_collision(dino.x);
             if (dino_duck_delay ==0)
             {
               put_sprite_3 = dino_duck3;// пустой спрайт
               put_sprite(dino.x,dino.y);
              dino.duck =0; //если да то снимаем флаг прыжка
              dino.busy =0;// снимаем флаг запрета опроса кнопок
              dino.y = 18;
             }
            }


}
    else
{
     jump_delay--; // уменьшаем задержку прыжка
      if (jump_delay == 0) {// достигла 0
          jump_delay = di_jmp_dl[dino_jump_pointer];// обновим задержку с нового места массива
         if (dino_jump_pointer<4 || dino_jump_pointer>=6) {
          put_sprite_3 = dino_empty;// пустой спрайт
          put_sprite(dino.x,dino.y);// затрем предыдущее состояние
          //end = check_cactus_collision(dino.x);
            }
          dino.y = dino_jump[dino_jump_pointer];// обновим новую координату по y
          put_sprite_3 = dino.dino_ptr[dino.AnimFrame];// обновим спрайт
          put_sprite(dino.x,dino.y); // отрисуем в экран

      if (dino_jump_pointer!=8){ // достигли конца координат прыжка и его задержки?
            dino_jump_pointer++;// если нет то следующий
            }
            else
            {
             dino.jump =0; //если да то снимаем флаг прыжка
             dino.busy =0;// снимаем флаг запрета опроса кнопок
             
            }
        }
        
}
             
   
            
}



void check_player(void)
{
uint8_t kb=255;
if (dino.busy==1) return; // ядро занято отрисовкой и нет смысла жать кнопки и их отрабатывать
kb=0xff;
kb=key_scan(0xfd);// опросим клавиатуру

   if (kb==223) //жмем прыжок
    {
        dino.dino_ptr = Dino[0]; // набор спрайтов для летящего динозаврика (тут статика)
        dino.AnimFrame=0;// но начнем с начального тайла
        dino.jump = 1; // сообщение ядру что мы прыгаем
        dino.busy = 1; // сообщение этой функции в дальнейшем что мы заняты
        jump_delay = 1; // костыль (как же без него)
        dino_jump_pointer = 0;// указатель на массивы координат Y и задержки
    }
   if (kb==127)// жмем вниз
    {
        dino.dino_ptr = Dino[2];
        dino.duck = 1; 
        dino.y = 21;
        dino.busy = 1; // сообщение этой функции в дальнейшем что мы заняты
        dino_duck_delay = 20;
    }
   if (kb==239)//run left // немного от оригинала отошел - бежим влево
    {
        dino.x-=1;
        if (dino.x<left_x) dino.x=left_x; // ограничение
    }
 
   if (kb==191) // бежим вправо
    {
        dino.x+=1;
        if (dino.x>right_x) dino.x=right_x;
    }
//Мы ничего не делаем. Будем просто стоять.
   if (kb==255) // нет действий от пользователя
    {
       if (dino.dino_ptr != Dino[1])dino.dino_ptr = Dino[1]; // сменим набор спрайтов на бег
    }
}