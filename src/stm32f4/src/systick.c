#include <systick.h>
#include <stm32f4xx_gpio.h>
#include <stm32f4xx_it.h>

// 32 bit: this should be enough for about 68 years of continuous operation.
uint32_t secondsElapsed = 0;
uint16_t intermediateMillis = 0;

void InitialiseSysTick() {
  // init the system ticker to trigger an interrupt every millisecond
  // this will call the SysTick_Handler
  // note that milliseconds are only used because calling it every second (ideal) fails.
  // This is presumably due to the ideal number of ticks being too many to store in a register
  if (SysTick_Config(SystemCoreClock / 1000)) {
    HardFault_Handler();
  }
}

// note that the SysTick handler is already defined in startup_stm32f40xx.s
// It is defined with a weak reference, so that anyone other
// definition will be used over the default
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
