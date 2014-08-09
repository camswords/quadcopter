#include <stm32f4xx.h>
#include <stm32f4xx_gpio.h>
#include <delay.h>
#include <pwm.h>

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

// 32 bit: this should be enough for about 68 years of continuous operation.
uint32_t secondsElapsed = 0;
uint16_t intermediateMillis = 0;

void SysTick_Handler(void)
{
    intermediateMillis++;

    if (intermediateMillis == 1000) {
        intermediateMillis = 0;
        secondsElapsed++;

        if (secondsElapsed % 2 == 0) {
          GPIOD->BSRRH = 0xE000;
          GPIOD->BSRRL = 0x0000;
        } else {
          GPIOD->BSRRH = 0x0000;
          GPIOD->BSRRL = 0xE000;
        }
    }
}

int main(void) {
  InitialiseLEDs();
  InitialisePWM();
  InitialisePWMChannel();

  // init the system ticker to trigger an interrupt every millisecond
  // this will call the SysTick_Handler
  // note that milliseconds are only used because calling it every second (ideal)
  // fails. This is presumably due to the ideal number of ticks being too many to store
  // in a register
  if (SysTick_Config(SystemCoreClock / 1000)) {
    GPIOD->BSRRH = 0x0000;
    GPIOD->BSRRL = 0x2000;

    // hard fault
    while(1);
  }

  while(1);
}
