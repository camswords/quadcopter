#ifndef TIMER_H
#define TIMER_H

#include <stdint.h>

void InitialisePWM();
void InitialisePWMChannel(uint16_t pin, uint8_t pinSource, uint8_t channel);

#endif
