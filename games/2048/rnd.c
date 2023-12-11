#include "rnd.h"
#include "main.h"
//#include "tinymt32.h"

//#include <stdint.h>
//---------------------------------------------------------------------------
tinymt32_t MathTinyMt;


void _memset(void* s, u8 c, s16 size)
{
	volatile char* s1 = (char*)s;

	if(size == 0)
	{
		goto End;
	}

	size++;
	while(--size > 0)
	{
		*s1++ = c;
	}

End: ;
}

uint32_t tinymt32_temper(tinymt32_t * random) {
    uint32_t t0, t1;
    t0 = random->status[3];
#if defined(LINEARITY_CHECK)
    t1 = random->status[0]
	^ (random->status[2] >> TINYMT32_SH8);
#else
    t1 = random->status[0]
	+ (random->status[2] >> TINYMT32_SH8);
#endif
    t0 ^= t1;
    t0 ^= -((int32_t)(t1 & 1)) & random->tmat;
    return t0;
}


static void tinymt32_next_state(tinymt32_t * random) {
    uint32_t x;
    uint32_t y;

    y = random->status[3];
    x = (random->status[0] & TINYMT32_MASK)
	^ random->status[1]
	^ random->status[2];
    x ^= (x << TINYMT32_SH0);
    y ^= (y >> TINYMT32_SH0) ^ x;
    random->status[0] = random->status[1];
    random->status[1] = random->status[2];
    random->status[2] = x ^ (y << TINYMT32_SH1);
    random->status[3] = y;
    random->status[1] ^= -((int32_t)(y & 1)) & random->mat1;
    random->status[2] ^= -((int32_t)(y & 1)) & random->mat2;
}

static uint32_t tinymt32_generate_uint32(tinymt32_t * random) {
    tinymt32_next_state(random);
    return tinymt32_temper(random);
}

static void period_certification(tinymt32_t * random) {
    if ((random->status[0] & TINYMT32_MASK) == 0 &&
	random->status[1] == 0 &&
	random->status[2] == 0 &&
	random->status[3] == 0) {
	random->status[0] = 'T';
	random->status[1] = 'I';
	random->status[2] = 'N';
	random->status[3] = 'Y';
    }
}

void tinymt32_init(tinymt32_t * random, uint32_t seed) {
    random->status[0] = seed;
    random->status[1] = random->mat1;
    random->status[2] = random->mat2;
    random->status[3] = random->tmat;
    for (int i = 1; i < MIN_LOOP; i++) {
	random->status[i & 3] ^= i + (long)1812433253    * (random->status[(i - 1) & 3]    ^ (random->status[(i - 1) & 3] >> 30));
    }
    period_certification(random);
    for (int i = 0; i < PRE_LOOP; i++) {
	tinymt32_next_state(random);
    }
}

//---------------------------------------------------------------------------
void RndInit(void)
{
	tinymt32_init(&MathTinyMt, 0xF67C129B);
}
//---------------------------------------------------------------------------
void RndInitSeed(u32 num)
{
	tinymt32_init(&MathTinyMt, num);
}
//---------------------------------------------------------------------------
u32 Rnd32(void)
{
	return tinymt32_generate_uint32(&MathTinyMt);
}
//---------------------------------------------------------------------------
u32 Rnd(u32 num)
{
	s32 ret = Rnd32() % num;

	if(ret < 0)
	{
		ret *= -1;
	}

	return ret;
}
