#include <stm32f4xx.h>
#include <stm32f4xx_gpio.h>
#include <delay.h>
#include <pwm.h>
#include <systick.h>

void InitialiseLEDs()
{
    RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOD, ENABLE);

    GPIO_InitTypeDef gpioStructure;
    gpioStructure.GPIO_Pin = GPIO_Pin_13 | GPIO_Pin_14 | GPIO_Pin_15;
    gpioStructure.GPIO_Mode = GPIO_Mode_OUT;
    gpioStructure.GPIO_Speed = GPIO_Speed_100MHz;
    gpioStructure.GPIO_OType = GPIO_OType_PP;
    gpioStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
    GPIO_Init(GPIOD, &gpioStructure);
}

void TurnOnLeds() {
    GPIOD->BSRRH = 0x0000;
    GPIOD->BSRRL = 0xE000;
}

void TurnOffLeds() {
    GPIOD->BSRRH = 0xE000;
    GPIOD->BSRRL = 0x0000;
}

int main(void) {
  InitialiseLEDs();
  InitialiseSysTick();
  InitialisePWM();
  InitialisePWMChannel();

  AddCallback(1, &TurnOnLeds);
  AddCallback(2, &TurnOffLeds);
  AddCallback(3, &TurnOnLeds);
  AddCallback(4, &TurnOffLeds);
  AddCallback(5, &TurnOnLeds);
  AddCallback(10, &TurnOffLeds);

  while(1);
}
