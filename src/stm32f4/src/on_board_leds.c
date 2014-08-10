#include <on_board_leds.h>

void InitialiseLeds() {
    RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOD, ENABLE);

    GPIO_InitTypeDef gpioStructure;
    gpioStructure.GPIO_Pin = YELLOW_LED | ORANGE_LED | RED_LED | BLUE_LED;
    gpioStructure.GPIO_Mode = GPIO_Mode_OUT;
    gpioStructure.GPIO_Speed = GPIO_Speed_100MHz;
    gpioStructure.GPIO_OType = GPIO_OType_PP;
    gpioStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
    GPIO_Init(GPIOD, &gpioStructure);
}

void TurnOn(uint16_t leds) {
    GPIOD->BSRRL = leds;
}

void TurnOff(uint16_t leds) {
    GPIOD->BSRRH = leds;
}
