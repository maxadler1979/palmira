#ifndef __MAIN_H
#define __MAIN_H

#define pgm_read_byte(x) (*((uint8_t*)x))
#define pgm_read_word(x) (*((uint16_t*)x))
#define pgm_read_ptr(x) (*((unsigned char*)x))


#define VIDEO_BPL 78
//#define uint8_t unsigned char
#define bool char
#define true 1
#define false 0
#define uint8_t  unsigned char
#define uint16_t unsigned int
#define int32_t  long
#define nullptr  0
#define int8_t   char
#define int16_t  int

#define SCREEN 0x6a00

#define KEY_enter    251
#define KEY_space    127 //
#define KEY_left     239
#define KEY_right    191
#define KEY_up       223
#define KEY_down     127





void clrscr(void);
void put_sprite(char x,char y);
void create_table(void);
#define FONT_WIDTH 4
#define FONT_HEIGHT 6
void DrawInt(int16_t val, uint8_t x, uint8_t y);
void scroll(void);
void put_tile(char x,char y, char st);
void cactus_check(void);
void cactus_core(void);
void dino_init(void);
void put_cactus(char x,char y, char st);
void dino_core(void);
void check_player(void);
int random(int min, int max);
uint8_t key_scan(uint8_t row);

void check_cactus_collision(uint8_t x_cactus);
void check_ptero_collision( uint8_t x_ptero,uint8_t y_ptero);

void cactus_init(void);
void DrawUInt(uint16_t val, uint8_t x, uint8_t y);
void DrawScore(uint8_t x, uint8_t y);
void inc_score(void);
void ptero_init(void);
void put_ptero(char x,char y, char st);
void ptero_check(void);
void ptero_core(void);

#endif 