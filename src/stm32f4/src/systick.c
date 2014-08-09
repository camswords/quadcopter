#include <systick.h>
#include <stm32f4xx_gpio.h>

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
