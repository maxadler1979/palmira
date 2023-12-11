#include "main.h"
#define TINYMT32_MASK (unsigned long)0x7fffffff




#define MIN_LOOP 8
#define PRE_LOOP 8

#define TINYMT32_SH0 1
#define TINYMT32_SH1 10
#define TINYMT32_SH8 8


struct TINYMT32_T {
    uint32_t status[4];
    uint32_t mat1;
    uint32_t mat2;
    uint32_t tmat;
};

typedef struct TINYMT32_T tinymt32_t;



void RndInit(void);
void RndInitSeed(u32 num);

u32  Rnd32(void);
u32  Rnd(u32 num);




