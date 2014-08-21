#include <stm32f4xx.h>
#include <stm32f4xx_gpio.h>
#include <delay.h>
#include <pwm.h>
#include <systick.h>
#include <on_board_leds.h>
#include <pwm_input.h>



int main(void) {
  uint8_t toggle = 0;

  EnableTiming();
  InitialiseLeds();
  InitialiseSysTick();
  InitialisePWM();
  CapturePWMInput();    // captured on B7

  DutyCycle dutyCycle1 = InitialisePWMChannel(GPIOA, GPIO_Pin_6, GPIO_PinSource6, 1);
  DutyCycle dutyCycle2 = InitialisePWMChannel(GPIOA, GPIO_Pin_7, GPIO_PinSource7, 2);
  DutyCycle dutyCycle3 = InitialisePWMChannel(GPIOB, GPIO_Pin_0, GPIO_PinSource0, 3);
  DutyCycle dutyCycle4 = InitialisePWMChannel(GPIOB, GPIO_Pin_1, GPIO_PinSource1, 4);

  dutyCycle1.update(1100);
  dutyCycle2.update(1200);
  dutyCycle3.update(1800);
  // dutyCycle4 should be 2000

  while(1) {
    TurnOff(RED_LED | ORANGE_LED | YELLOW_LED | BLUE_LED);

    if (pwmInput.dutyCycle <= 0 || pwmInput.dutyCycle >= 100) {
      if (++toggle % 2 == 0) {
        TurnOn(RED_LED);
      }
    } else {
      if (pwmInput.dutyCycle > 0 && pwmInput.dutyCycle < 19) {
        TurnOn(BLUE_LED);
      } else if (pwmInput.dutyCycle >= 19 && pwmInput.dutyCycle < 79) {
        TurnOn(ORANGE_LED);
      } else if (pwmInput.dutyCycle >= 79 && pwmInput.dutyCycle < 99) {
        TurnOn(YELLOW_LED);
      } else if (pwmInput.dutyCycle >= 79 && pwmInput.dutyCycle < 99) {
        TurnOn(YELLOW_LED | ORANGE_LED | BLUE_LED);
      } else {
        TurnOn(RED_LED | BLUE_LED);
      }
    }

    // wait a second!
    TimingDelay(168000000);
  }
}
