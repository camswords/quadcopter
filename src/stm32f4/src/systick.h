#ifndef SYSTICK_H
#define SYSTICK_H

#include <stdint.h>

typedef void (*callback)(void);

void InitialiseSysTick(void);

void AddCallback(uint32_t seconds, callback event);

#endif
