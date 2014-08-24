
#ifndef PWM_INPUT_H
#define PWM_INPUT_H

#include <stdint.h>
#include <stm32f4xx_tim.h>

typedef struct PWMInput {
    uint16_t dutyCycle;
    uint32_t frequency;

}PWMInput;

struct PWMInput pwmInput;

void BreakOnTimerCount();

#endif
