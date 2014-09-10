#include <stm32f4xx.h>
#include <stm32f4xx_gpio.h>
#include <delay.h>
#include <pwm.h>
#include <systick.h>
#include <on_board_leds.h>
#include <pwm_input.h>
#include <i2c.h>
#include <gyroscope.h>
#include <accelerometer.h>
#include <magnetometer.h>
#include <serial_output.h>

/* Performance fun tips:
 * Use the native register size wherever possible (32bit!). That way the processor doesn't have to do fancy scaling to get your register to the size it can handle
 */


int main(void) {
  EnableTiming();
  InitialiseLeds();
  InitialiseSysTick();
  InitialisePWM();
  InitialiseI2C();	// PB.08, PB.09
  InitialiseSerialOutput(); // PC.10 (TX) and PC.11 (RX)
  InitialiseGyroscope();
  InitialiseAccelerometer();
  InitialiseMagnetometer();
  struct AccelerometerReading accelerometerReading = CreateAccelerometerReading();
  struct MagnetometerReading magnetometerReading = CreateMagnetometerReading();

  /* throttle: all together now! power (collective pitch?) */
  struct PWMInput* throttle = MeasurePWMInput(TIM4, GPIOB, GPIO_Pin_6, GPIO_PinSource6); 	// channel 2 - PB.07

  /* rudder: spin to the left or right on a flat plane */
  struct PWMInput* rudder = MeasurePWMInput(TIM5, GPIOA, GPIO_Pin_0, GPIO_PinSource0); 		// channel 2 - PA.01

  /* airleron: fly sideways left or right */
  struct PWMInput* airleron = MeasurePWMInput(TIM9, GPIOE, GPIO_Pin_5, GPIO_PinSource5);	// channel 2 - PE.05

  /* elevator: fly forwards or backwards */
  struct PWMInput* elevator = MeasurePWMInput(TIM12, GPIOB, GPIO_Pin_14, GPIO_PinSource14); // channel 2 - PB.15

  // Uses Timer #3
  DutyCycle dutyCycle1 = InitialisePWMChannel(GPIOA, GPIO_Pin_6, GPIO_PinSource6, 1);
  DutyCycle dutyCycle2 = InitialisePWMChannel(GPIOA, GPIO_Pin_7, GPIO_PinSource7, 2);
  DutyCycle dutyCycle3 = InitialisePWMChannel(GPIOB, GPIO_Pin_0, GPIO_PinSource0, 3);
  DutyCycle dutyCycle4 = InitialisePWMChannel(GPIOB, GPIO_Pin_1, GPIO_PinSource1, 4);

  dutyCycle1.update(1100);	// 10%  throttle
  dutyCycle2.update(1200);	// 20%  throttle
  dutyCycle3.update(1800);	// 80%  throttle
  dutyCycle4.update(2000);	// 100% throttle

  TurnOn(BLUE_LED);

  uint16_t loopFrequency = 0;
  uint32_t mySeconds = 0;

  while(1) {
	  if(secondsElapsed != mySeconds) {
		  mySeconds = secondsElapsed;
		  RecordAnalytics("loop.freq", secondsElapsed, loopFrequency);
		  RecordFloatAnalytics("gyro.xval", secondsElapsed, gyroscopeReading.x);
		  loopFrequency = 0;
	  }

	  loopFrequency++;

	  ReadGyroscope(&gyroscopeReading);
	  ReadAccelerometer(&accelerometerReading);
	  ReadMagnetometer(&magnetometerReading);
  }
}
