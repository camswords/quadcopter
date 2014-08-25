#include <stm32f4xx.h>
#include <stm32f4xx_gpio.h>
#include <delay.h>
#include <pwm.h>
#include <systick.h>
#include <on_board_leds.h>
#include <pwm_input.h>



int main(void) {
  EnableTiming();
  InitialiseLeds();
  InitialiseSysTick();
  InitialisePWM();
  struct PWMInput* throttle = MeasurePWMInput(TIM4, GPIOB, GPIO_Pin_6, GPIO_PinSource6);

  DutyCycle dutyCycle1 = InitialisePWMChannel(GPIOA, GPIO_Pin_6, GPIO_PinSource6, 1);
  DutyCycle dutyCycle2 = InitialisePWMChannel(GPIOA, GPIO_Pin_7, GPIO_PinSource7, 2);
  DutyCycle dutyCycle3 = InitialisePWMChannel(GPIOB, GPIO_Pin_0, GPIO_PinSource0, 3);
  DutyCycle dutyCycle4 = InitialisePWMChannel(GPIOB, GPIO_Pin_1, GPIO_PinSource1, 4);

  dutyCycle1.update(1100);
  dutyCycle2.update(1200);
  dutyCycle3.update(1800);
  // dutyCycle4 should be 2000

  TurnOn(BLUE_LED);

  while(1) {
	  // wait a second!
	  TimingDelay(160000000);
  }
}
