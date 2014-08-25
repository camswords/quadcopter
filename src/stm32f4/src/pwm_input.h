
#ifndef PWM_INPUT_H
#define PWM_INPUT_H

#include <stm32f4xx_tim.h>

typedef struct PWMInput {
    float dutyCycle;
    float frequency;

}PWMInput;

struct PWMInput pwmInputTimer4;

struct PWMInput* MeasurePWMInput();

#endif
