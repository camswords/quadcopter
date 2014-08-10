#ifndef TIMER_H
#define TIMER_H

#include <stdint.h>
#include <stm32f4xx_gpio.h>

void InitialisePWM();
void InitialisePWMChannel(GPIO_TypeDef* GPIOx, uint16_t pin, uint8_t pinSource, uint8_t channel);

#endif
