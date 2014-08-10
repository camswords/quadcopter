#ifndef ONBOARD_LEDS_H
#define ONBOARD_LEDS_H

#include <stm32f4xx_gpio.h>

#define YELLOW_LED GPIO_Pin_12
#define ORANGE_LED GPIO_Pin_13
#define RED_LED    GPIO_Pin_14
#define BLUE_LED   GPIO_Pin_15

void InitialiseLeds(void);

void TurnOn(uint16_t leds);
void TurnOff(uint16_t leds);

#endif
