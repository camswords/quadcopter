
#ifndef SYSTICK_H
#define SYSTICK_H

// note that the SysTick handler is already defined in startup_stm32f40xx.s
// It is defined with a weak reference, so that anyone other
// definition will be used over the default
void SysTick_Handler(void);

#endif
