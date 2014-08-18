#include <systick.h>
#include <stm32f4xx_gpio.h>
#include <stm32f4xx_it.h>


// 32 bit: this should be enough for about 68 years of continuous operation.
// note that if interrupts interrupt each other, this value may
// be relatively inaccurate regarding seconds elapsed.
uint32_t secondsElapsed = 0;


// 32 bit: this should be enough for 49.7 days on continuous operation.
// note that if interrupts interrupt each other, this value may
// be relatively inaccurate regarding milliseconds elapsed.
uint32_t intermediateMillis = 0;


void InitialiseSysTick() {
  // init the system ticker to trigger an interrupt every millisecond
  // this will call the SysTick_Handler
  // note that milliseconds are only used because calling it every second (ideal) fails.
  // This is presumably due to the ideal number of ticks being too many to store in a register.

  if (SysTick_Config(SystemCoreClock / 1000)) {
    HardFault_Handler();
  }
}

// note that the SysTick handler is already defined in startup_stm32f40xx.s
// It is defined with a weak reference, so that anyone other definition will be used over the default
void SysTick_Handler(void)
{
    intermediateMillis++;

    if (intermediateMillis % 1000 == 0) {
        secondsElapsed++;
    }

    // After 49 days, what to do? Kaboom! Until we require something better.
    if (intermediateMillis == UINT_LEAST32_MAX) {
        HardFault_Handler();
    }
}
