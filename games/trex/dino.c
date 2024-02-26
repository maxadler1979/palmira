

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
// �������� �� ������������ � ��������

 
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
// �������� �� ������������ � ��������
 
 
if (dino.x+5 >= x_ptero) 
    {
    if (dino.x+5<= x_ptero+9)
        {
         if (y_ptero == 20){// ����� �����
                if (dino.y>=12) {
                end = 1;
                dino.dino_ptr = Dino[3]; //Dino_died
               
                }
            }
         if (y_ptero == 13){// ����� ������
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
 

  if (dino.jump !=1) // ���� �� �������
{           
             put_sprite_3 = dino.dino_ptr[dino.AnimFrame]; // �������� ������� ������
             put_sprite(dino.x,dino.y); // ������� �� �����������
             dino.AnimFrame_delay++;
             if (dino.AnimFrame_delay==2)
             {
             if (dino.AnimFrame==0) dino.AnimFrame = 1; else dino.AnimFrame = 0; // ������� ������ (������ �������)
             dino.AnimFrame_delay=0;
             }

            if (dino.duck==1)
            {
                if (dino_duck_delay ==20)
                {
                 put_sprite_3 = dino_empty;// ������ ������
                 put_sprite(dino.x,18);
                }
             dino_duck_delay --;
            // end = check_cactus_collision(dino.x);
             if (dino_duck_delay ==0)
             {
               put_sprite_3 = dino_duck3;// ������ ������
               put_sprite(dino.x,dino.y);
              dino.duck =0; //���� �� �� ������� ���� ������
              dino.busy =0;// ������� ���� ������� ������ ������
              dino.y = 18;
             }
            }


}
    else
{
     jump_delay--; // ��������� �������� ������
      if (jump_delay == 0) {// �������� 0
          jump_delay = di_jmp_dl[dino_jump_pointer];// ������� �������� � ������ ����� �������
         if (dino_jump_pointer<4 || dino_jump_pointer>=6) {
          put_sprite_3 = dino_empty;// ������ ������
          put_sprite(dino.x,dino.y);// ������ ���������� ���������
          //end = check_cactus_collision(dino.x);
            }
          dino.y = dino_jump[dino_jump_pointer];// ������� ����� ���������� �� y
          put_sprite_3 = dino.dino_ptr[dino.AnimFrame];// ������� ������
          put_sprite(dino.x,dino.y); // �������� � �����

      if (dino_jump_pointer!=8){ // �������� ����� ��������� ������ � ��� ��������?
            dino_jump_pointer++;// ���� ��� �� ���������
            }
            else
            {
             dino.jump =0; //���� �� �� ������� ���� ������
             dino.busy =0;// ������� ���� ������� ������ ������
             
            }
        }
        
}
             
   
            
}



void check_player(void)
{
uint8_t kb=255;
if (dino.busy==1) return; // ���� ������ ���������� � ��� ������ ���� ������ � �� ������������
kb=0xff;
kb=key_scan(0xfd);// ������� ����������

   if (kb==223) //���� ������
    {
        dino.dino_ptr = Dino[0]; // ����� �������� ��� �������� ����������� (��� �������)
        dino.AnimFrame=0;// �� ������ � ���������� �����
        dino.jump = 1; // ��������� ���� ��� �� �������
        dino.busy = 1; // ��������� ���� ������� � ���������� ��� �� ������
        jump_delay = 1; // ������� (��� �� ��� ����)
        dino_jump_pointer = 0;// ��������� �� ������� ��������� Y � ��������
    }
   if (kb==127)// ���� ����
    {
        dino.dino_ptr = Dino[2];
        dino.duck = 1; 
        dino.y = 21;
        dino.busy = 1; // ��������� ���� ������� � ���������� ��� �� ������
        dino_duck_delay = 20;
    }
   if (kb==239)//run left // ������� �� ��������� ������ - ����� �����
    {
        dino.x-=1;
        if (dino.x<left_x) dino.x=left_x; // �����������
    }
 
   if (kb==191) // ����� ������
    {
        dino.x+=1;
        if (dino.x>right_x) dino.x=right_x;
    }
//�� ������ �� ������. ����� ������ ������.
   if (kb==255) // ��� �������� �� ������������
    {
       if (dino.dino_ptr != Dino[1])dino.dino_ptr = Dino[1]; // ������ ����� �������� �� ���
    }
}