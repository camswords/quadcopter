
#ifndef __DELAY_H
#define __DELAY_H

#include <stdint.h>

void EnableTiming();
void TimingDelay(unsigned int tick);
void WaitASecond();
void WaitAFewMillis(int16_t millis);

#endif
