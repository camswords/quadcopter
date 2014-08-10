#include <stdint.h>

#ifndef SYSTICK_H
#define SYSTICK_H

typedef void (*callback)(void);

void InitialiseSysTick(void);

void AddCallback(uint32_t seconds, callback event);

#endif
