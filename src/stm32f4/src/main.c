#include <stm32f4xx.h>
#include <stm32f4xx_gpio.h>
#include <delay.h>
#include <pwm.h>
#include <systick.h>
#include <on_board_leds.h>

int main(void) {
  InitialiseLeds();
  InitialiseSysTick();
  InitialisePWM();

  InitialisePWMChannel(GPIOA, GPIO_Pin_6, GPIO_PinSource6, 1);
  InitialisePWMChannel(GPIOA, GPIO_Pin_7, GPIO_PinSource7, 2);
  InitialisePWMChannel(GPIOB, GPIO_Pin_0, GPIO_PinSource0, 3);
  InitialisePWMChannel(GPIOB, GPIO_Pin_1, GPIO_PinSource1, 4);

  TurnOn(BLUE_LED);

  while(1);
}
