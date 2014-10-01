#ifndef TIMER_H
#define TIMER_H

#include <stdint.h>
#include <stm32f4xx_gpio.h>

typedef void (*DutyCycleModifier)(float);
typedef void (*DutyCycleSetter)(float);
typedef float (*DutyCycleReader)();

float channel1Pulse;
float channel2Pulse;
float channel3Pulse;
float channel4Pulse;

typedef struct DutyCycle {
	DutyCycleSetter set;
    DutyCycleModifier update;
    DutyCycleReader get;
}DutyCycle;

void InitialisePWM();
DutyCycle InitialisePWMChannel(GPIO_TypeDef* GPIOx, uint16_t pin, uint8_t pinSource, uint8_t channel);

#endif
