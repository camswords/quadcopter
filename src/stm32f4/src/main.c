#include <stdint.h>

//#include <pwm_input.h>
#include "../Libraries/STM32F4xx_StdPeriph_Driver/inc/stm32f4xx_gpio.h"
#include "accelerometer.h"
#include "analytics.h"
#include "angular_position.h"
#include "configuration.h"
#include "delay.h"
#include "gyroscope.h"
#include "i2c.h"
#include "on_board_leds.h"
#include "panic.h"
#include "pid.h"
#include "pwm.h"
#include "remote_controls.h"
#include "stm32f4xx.h"
#include "systick.h"
#include <stdlib.h>

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
		  float xPidProportional = ReadRemoteXPidProportional();
		  float yPidProportional = ReadRemoteYPidProportional();
		  xAxisPid = InitialisePid(xPidProportional, 0, 0);
		  yAxisPid = InitialisePid(yPidProportional, 0, 0);

		  uint8_t loopReference = rand() & 0xFF;

		  RecordIntegerMetric(METRIC_SECONDS_ELAPSED, loopReference, secondsElapsed);
		  RecordIntegerMetric(METRIC_LOOP_FREQUENCY, loopReference, loopsPerSecond);
		  RecordFloatMetric(METRIC_GYROSCOPE_X_POSITION, loopReference, gyroscopeReading.x);
		  RecordFloatMetric(METRIC_GYROSCOPE_Y_POSITION, loopReference, gyroscopeReading.y);
		  RecordFloatMetric(METRIC_GYROSCOPE_Z_POSITION, loopReference, gyroscopeReading.z);
		  RecordFloatMetric(METRIC_GYROSCOPE_TEMPERATURE, loopReference, gyroscopeReading.gyroscopeTemperature);
		  RecordIntegerMetric(METRIC_GYROSCOPE_SAMPLE_RATE, loopReference, gyroscopeReading.readings);
		  RecordFloatMetric(METRIC_PROPELLOR_B_SPEED, loopReference, bProp.get());
		  RecordFloatMetric(METRIC_PROPELLOR_E_SPEED, loopReference, eProp.get());
		  RecordFloatMetric(METRIC_PROPELLOR_C_SPEED, loopReference, cProp.get());
		  RecordFloatMetric(METRIC_PROPELLOR_A_SPEED, loopReference, aProp.get());
		  RecordFloatMetric(METRIC_PID_X_ADJUSTMENT, loopReference, xAdjustment);
		  RecordFloatMetric(METRIC_PID_Y_ADJUSTMENT, loopReference, yAdjustment);
		  RecordFloatMetric(METRIC_REMOTE_X_PID_PROPORTIONAL, loopReference, xPidProportional);
		  RecordFloatMetric(METRIC_REMOTE_Y_PID_PROPORTIONAL, loopReference, yPidProportional);
		  RecordFloatMetric(METRIC_REMOTE_THROTTLE, loopReference, currentThrottle);
		  RecordFloatMetric(METRIC_ACCELEROMETER_X_POSITION, loopReference, accelerometerReading.x);
		  RecordFloatMetric(METRIC_ACCELEROMETER_Y_POSITION, loopReference, accelerometerReading.y);
		  RecordFloatMetric(METRIC_ACCELEROMETER_Z_POSITION, loopReference, accelerometerReading.z);
		  RecordIntegerMetric(METRIC_ACCELEROMETER_SAMPLE_RATE, loopReference, accelerometerReading.readings);
		  RecordFloatMetric(METRIC_ANGULAR_X_POSITION, loopReference, angularPosition.x);
		  RecordFloatMetric(METRIC_ANGULAR_Y_POSITION, loopReference, angularPosition.y);
		  RecordFloatMetric(METRIC_ANGULAR_Z_POSITION, loopReference, angularPosition.z);
		  RecordIntegerMetric(METRIC_METRICS_BUFFER_SIZE, loopReference, metricsRingBuffer.count);
		  RecordFloatMetric(METRIC_DEBUG_VALUE_1, loopReference, throttle->dutyCycle);
		  RecordFloatMetric(METRIC_DEBUG_VALUE_2, loopReference, throttle->frequency);

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
