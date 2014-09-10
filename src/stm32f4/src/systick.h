#ifndef SYSTICK_H
#define SYSTICK_H

#include <stdint.h>

// 32 bit: this should be enough for about 68 years of continuous operation.
// note that if interrupts interrupt each other, this value may
// be relatively inaccurate regarding seconds elapsed.
uint32_t secondsElapsed;

// 32 bit: this should be enough for 49.7 days on continuous operation.
// note that if interrupts interrupt each other, this value may
// be relatively inaccurate regarding milliseconds elapsed.
uint32_t intermediateMillis;


void InitialiseSysTick(void);

#endif
