#include <stm32f4xx.h>
#include <stm32f4xx_gpio.h>
#include <delay.h>
#include <pwm.h>
#include <systick.h>


int main(void) {
  RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOD, ENABLE);
  InitialisePWM();
  InitialisePWMChannel(GPIO_Pin_12, GPIO_PinSource12, 1);
  InitialisePWMChannel(GPIO_Pin_13, GPIO_PinSource13, 2);
  InitialisePWMChannel(GPIO_Pin_14, GPIO_PinSource14, 3);
  InitialisePWMChannel(GPIO_Pin_15, GPIO_PinSource15, 4);

  while(1);
}
