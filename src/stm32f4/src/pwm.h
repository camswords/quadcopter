#ifndef TIMER_H
#define TIMER_H

#include <stdint.h>
#include <stm32f4xx_gpio.h>

typedef void (*DutyCycleModifier)(uint32_t);

typedef struct DutyCycle {
    DutyCycleModifier update;
}DutyCycle;

void InitialisePWM();
DutyCycle InitialisePWMChannel(GPIO_TypeDef* GPIOx, uint16_t pin, uint8_t pinSource, uint8_t channel);

#endif
