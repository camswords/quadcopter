#include <stm32f4xx.h>
#include <stm32f4xx_gpio.h>
#include <delay.h>
#include <pwm.h>
#include <systick.h>
#include <on_board_leds.h>
#include <pwm_input.h>
#include <i2c.h>
#include <analytics.h>
#include <angular_position.h>
#include <pid.h>
#include <remote_controls.h>
#include <gyroscope.h>
#include <accelerometer.h>
#include <panic.h>
#include <stdint.h>
#include <configuration.h>

/* Performance fun tips:
 * Use the native register size wherever possible (32bit!). That way the processor doesn't have to do fancy scaling to get your register to the size it can handle
 * compile using hard float support
 */

/* Before attempting to fly:
 * understand the maximum and minimum airleron / elevator / rudder / throttle values
 * build a start motors sequence
 */

/* Things to do:
 *   - add a high pass filter to the gyroscope
 *   - add a low pass filter to the accelerometer
 *   - combine their outputs using a complimentary filter
 */

int main(void) {
  EnableTiming();
  InitialiseLeds();
  InitialisePanicButton();

  TurnOn(ORANGE_LED);

  InitialiseSysTick();

  InitialiseAnalytics(); // PC.10 (TX) and PC.11 (RX)
  InitialisePWM();
  ResetI2C();
  InitialiseI2C();	// PB.08 (SCL), PB.09 (SDA)
  Pid xAxisPid = InitialisePid(10, 0, 0);	/* a 1 degree angle will affect the power distribution by + / - 20 */
  Pid yAxisPid = InitialisePid(10, 0, 0);


  /*
   * Throttle: PB.06 (TIM4),  Channel 1 (PB.07 indirectly used)
   * Rudder:   PA.00 (TIM5),  Channel 4 (PA.01 indirectly used)
   * Airleron: PE.05 (TIM9),  Channel 2 (PE.06 indirectly used)
   * Elevator: PB.14 (TIM12), Channel 3 (PB.15 indirectly used)
   */
  InitialiseRemoteControls();

  // Uses Timer #3
  DutyCycle bProp = InitialisePWMChannel(GPIOA, GPIO_Pin_6, GPIO_PinSource6, 1); 		// (x axis)
  DutyCycle eProp = InitialisePWMChannel(GPIOA, GPIO_Pin_7, GPIO_PinSource7, 2);	// (x axis)
  DutyCycle cProp = InitialisePWMChannel(GPIOB, GPIO_Pin_0, GPIO_PinSource0, 3);		// (y axis)
  DutyCycle aProp = InitialisePWMChannel(GPIOB, GPIO_Pin_1, GPIO_PinSource1, 4);	// (y axis)

  /* note: should introduce yaw, pitch roll into this */
  /* full throttle for two seconds */
  bProp.set(2000);
  eProp.set(2000);
  cProp.set(2000);
  aProp.set(2000);

  WaitAFewMillis(2000);

  /* low throttle for two seconds */
  bProp.set(1000);
  eProp.set(1000);
  cProp.set(1000);
  aProp.set(1000);

  WaitAFewMillis(2000);

  TurnOff(ORANGE_LED);
  TurnOn(YELLOW_LED);

  /* intitalise after the motors, this should give it some time for the temparature to stabalise */
  InitialiseAngularPosition();

  TurnOff(YELLOW_LED);
  TurnOn(BLUE_LED);

  /* go go go! */


  uint16_t loopsPerSecond = 0;
  uint32_t thisSecond = 0;

  while(1) {
	  loopsPerSecond++;
	  ReadAngularPosition();

	  /* ideally, we want this to return a value between -500 and 500 */
	  float xAdjustment = CalculatePidAdjustment(&xAxisPid, angularPosition.x, 0.0);
	  float yAdjustment = CalculatePidAdjustment(&yAxisPid, angularPosition.y, 0.0);

	  float currentThrottle = ReadRemoteThrottle();

	  if (currentThrottle == 0.0) {
		  bProp.set(1000);
		  eProp.set(1000);
		  cProp.set(1000);
		  aProp.set(1000);
	  } else {
		  float normalisedThrottle = (1000 * currentThrottle / 100.0) + 1000.0;

		  bProp.set(yAdjustment + normalisedThrottle);
		  eProp.set(-yAdjustment + normalisedThrottle);
		  cProp.set(xAdjustment + normalisedThrottle);
		  aProp.set(-xAdjustment + normalisedThrottle);
	  }

	  if (thisSecond != secondsElapsed) {
		  float thisPidProportional = 10;
//		  float thisPidProportional = ReadRemotePidProportional();
//		  xAxisPid = InitialisePid(thisPidProportional, 0, 0);
//		  yAxisPid = InitialisePid(thisPidProportional, 0, 0);

		  RecordMetric("loop.freq", secondsElapsed, loopsPerSecond);
//		  RecordMetric("gyro.posx", secondsElapsed, gyroscopeReading.x);
//		  RecordMetric("gyro.posy", secondsElapsed, gyroscopeReading.y);
//		  RecordMetric("gyro.posz", secondsElapsed, gyroscopeReading.z);
//		  RecordMetric("gyro.temp", secondsElapsed, gyroscopeReading.gyroscopeTemperature);
		  RecordMetric("gyro.freq", secondsElapsed, gyroscopeReading.readings);
		  RecordMetric("b---.prop", secondsElapsed, bProp.get());
		  RecordMetric("e---.prop", secondsElapsed, eProp.get());
		  RecordMetric("c---.prop", secondsElapsed, cProp.get());
		  RecordMetric("a---.prop", secondsElapsed, aProp.get());
		  RecordMetric("xadj.pid-", secondsElapsed, xAdjustment);
		  RecordMetric("yadj.pid-", secondsElapsed, yAdjustment);
		  RecordMetric("pval.remo", secondsElapsed, thisPidProportional);
		  RecordMetric("thro.remo", secondsElapsed, currentThrottle);
//		  RecordMetric("acce.posx", secondsElapsed, accelerometerReading.x);
//		  RecordMetric("acce.posy", secondsElapsed, accelerometerReading.y);
//		  RecordMetric("acce.posz", secondsElapsed, accelerometerReading.z);
		  RecordMetric("acce.freq", secondsElapsed, accelerometerReading.readings);
		  RecordMetric("angu.posx", secondsElapsed, angularPosition.x);
		  RecordMetric("angu.posy", secondsElapsed, angularPosition.y);
		  RecordMetric("angu.posz", secondsElapsed, angularPosition.z);
//		  RecordMetric("metr.buff", secondsElapsed, metricsRingBuffer.count);

		  loopsPerSecond = 0;
		  accelerometerReading.readings = 0;
		  gyroscopeReading.readings = 0;
		  thisSecond = secondsElapsed;
		  ClearWarnings();
	  }

	  if (intermediateMillis % ANALYTICS_FLUSH_FREQUENCY == 0) {
		  FlushMetrics();
	  }
  }
}
