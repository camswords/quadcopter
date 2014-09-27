#include <stm32f4xx.h>
#include <stm32f4xx_gpio.h>
#include <delay.h>
#include <pwm.h>
#include <systick.h>
#include <on_board_leds.h>
#include <pwm_input.h>
#include <i2c.h>
#include <serial_output.h>
#include <angular_position.h>
#include <pid.h>

/* Performance fun tips:
 * Use the native register size wherever possible (32bit!). That way the processor doesn't have to do fancy scaling to get your register to the size it can handle
 * compile using hard float support
 */

/* Before attempting to fly:
 * understand the maximum and minimum airleron / elevator / rudder / throttle values
 * build a start motors sequence
 */

int main(void) {
  EnableTiming();
  InitialiseLeds();
  InitialiseSysTick();
  InitialisePWM();
  InitialiseI2C();	// PB.08 (SCL), PB.09 (SDA)
  InitialiseSerialOutput(); // PC.10 (TX) and PC.11 (RX)
  Pid xAxisPid = InitialisePid(1, 0, 0);
  Pid yAxisPid = InitialisePid(1, 0, 0);

  /* throttle: all together now! power (collective pitch?) */
  struct PWMInput* throttle = MeasurePWMInput(TIM4, GPIOB, GPIO_Pin_6, GPIO_PinSource6); 	// channel 2 - PB.07

  /* rudder: spin to the left or right on a flat plane */
  struct PWMInput* rudder = MeasurePWMInput(TIM5, GPIOA, GPIO_Pin_0, GPIO_PinSource0); 		// channel 2 - PA.01

  /* airleron: fly sideways left or right */
  struct PWMInput* airleron = MeasurePWMInput(TIM9, GPIOE, GPIO_Pin_5, GPIO_PinSource5);	// channel 2 - PE.05

  /* elevator: fly forwards or backwards */
  struct PWMInput* elevator = MeasurePWMInput(TIM12, GPIOB, GPIO_Pin_14, GPIO_PinSource14); // channel 2 - PB.15

  // Uses Timer #3
  DutyCycle topLeftProp = InitialisePWMChannel(GPIOA, GPIO_Pin_6, GPIO_PinSource6, 1); 		// (x axis)
  DutyCycle bottomRightProp = InitialisePWMChannel(GPIOA, GPIO_Pin_7, GPIO_PinSource7, 2);	// (x axis)
  DutyCycle topRightProp = InitialisePWMChannel(GPIOB, GPIO_Pin_0, GPIO_PinSource0, 3);		// (y axis)
  DutyCycle bottomLeftProp = InitialisePWMChannel(GPIOB, GPIO_Pin_1, GPIO_PinSource1, 4);	// (y axis)

  /* full throttle for two seconds */
  topLeftProp.update(2000);
  bottomRightProp.update(2000);
  topRightProp.update(2000);
  bottomLeftProp.update(2000);

  WaitAFewMillis(2000);

  /* low throttle for two seconds */
  topLeftProp.update(1000);
  bottomRightProp.update(1000);
  topRightProp.update(1000);
  bottomLeftProp.update(1000);

  WaitAFewMillis(2000);

  /* intitalise after the motors, this should give it some time for the temparature to stabalise */
  InitialiseAngularPosition();

  /* go go go! */
  TurnOn(BLUE_LED);

  uint16_t loopsPerSecond = 0;
  uint32_t thisSecond = 0;

  while(1) {
	  loopsPerSecond++;

	  ReadAngularPosition();
	  float xAdjustment = CalculatePidAdjustment(&xAxisPid, angularPosition.x, 0.0);
	  float yAdjustment = CalculatePidAdjustment(&yAxisPid, angularPosition.y, 0.0);
	  float scaledThrottle = (2000 - throttle->dutyCycle) * 0.1;

	  topLeftProp.update(xAdjustment * scaledThrottle);
	  bottomRightProp.update(-xAdjustment * scaledThrottle);
	  topRightProp.update(yAdjustment * scaledThrottle);
	  bottomLeftProp.update(-yAdjustment * scaledThrottle);

	  if (thisSecond != secondsElapsed) {
		  RecordAnalytics("loop.freq", secondsElapsed, loopsPerSecond);
		  RecordFloatAnalytics("angu.posx", secondsElapsed, angularPosition.x);
		  RecordFloatAnalytics("angu.posy", secondsElapsed, angularPosition.y);
		  RecordFloatAnalytics("angu.posz", secondsElapsed, angularPosition.z);

		  loopsPerSecond = 0;
		  thisSecond = secondsElapsed;
	  }
  }
}
