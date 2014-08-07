#include <stm32f4xx.h>
#include <stm32f4xx_gpio.h>
#include <delay.h>

void InitialiseLEDs()
{
    RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOD, ENABLE);

    GPIO_InitTypeDef gpioStructure;
    gpioStructure.GPIO_Pin = GPIO_Pin_12 | GPIO_Pin_13 | GPIO_Pin_14 | GPIO_Pin_15;
    gpioStructure.GPIO_Mode = GPIO_Mode_OUT;
    gpioStructure.GPIO_Speed = GPIO_Speed_100MHz;
    gpioStructure.GPIO_OType = GPIO_OType_PP;
    gpioStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
    GPIO_Init(GPIOD, &gpioStructure);
}

int main(void) {
  EnableTiming();
  InitialiseLEDs();

  unsigned int toggle = 0;

  while(1) {
    if (toggle == 0) {
      GPIOD->BSRRH = 0x0000;
      GPIOD->BSRRL = 0xF000;
    } else {
      GPIOD->BSRRH = 0xF000;
      GPIOD->BSRRL = 0x0000;
    }

    if (toggle == 0) {
      toggle = 1;
    } else {
      toggle = 0;
    }

    // one second
    TimingDelay(SystemCoreClock);
  }
}
