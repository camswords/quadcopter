#include <stdint.h>

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
#include <stdbool.h>

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
	Pid xAxisPid = InitialisePid(3, 0, 0);
	Pid yAxisPid = InitialisePid(3, 0, 0);


	/*
	* Throttle: PB.06 (TIM4),  Channel 1 (PB.07 indirectly used)
	* Rudder:   PA.00 (TIM5),  Channel 4 (PA.01 indirectly used)
	* Airleron: PE.05 (TIM9),  Channel 2 (PE.06 indirectly used)
	* Elevator: PB.14 (TIM12), Channel 3 (PB.15 indirectly used)
	*/
	InitialiseRemoteControls();

	// Uses Timer #3
	DutyCycle bProp = InitialisePWMChannel(GPIOB, GPIO_Pin_1, GPIO_PinSource1, 4); 	// (y axis)
	DutyCycle eProp = InitialisePWMChannel(GPIOA, GPIO_Pin_7, GPIO_PinSource7, 2);	// (y axis)
	DutyCycle cProp = InitialisePWMChannel(GPIOB, GPIO_Pin_0, GPIO_PinSource0, 3);	// (x axis)
	DutyCycle aProp = InitialisePWMChannel(GPIOA, GPIO_Pin_6, GPIO_PinSource6, 1);	// (x axis)

	InitialiseAngularPosition();

	TurnOff(ORANGE_LED);
	TurnOn(YELLOW_LED);

	/* turn the motors off, until we get the go ahead from the user */
	uint8_t armingSequenceStep = ARMING_SEQUENCE_LOW_THROTTLE_REQUIRED;
	uint32_t armingSequenceTimeLastStepExecuted = 0;

	bProp.set(1000);
	eProp.set(1000);
	cProp.set(1000);
	aProp.set(1000);

	while (armingSequenceStep != ARMING_SEQUENCE_ARMED || ARMING_SEQUENCE_IS_DISABLED) {
		float thrust = ReadRemoteThrottle();

		if (secondsElapsed > armingSequenceTimeLastStepExecuted) {

			if (armingSequenceStep == ARMING_SEQUENCE_LOW_THROTTLE_REQUIRED && thrust == 0.0) {
				armingSequenceStep = ARMING_SEQUENCE_HIGH_THROTTLE_REQUIRED;
				armingSequenceTimeLastStepExecuted = secondsElapsed;

			} else if (armingSequenceStep == ARMING_SEQUENCE_HIGH_THROTTLE_REQUIRED && thrust == 100.0) {
				armingSequenceStep = ARMING_SEQUENCE_LOW_THROTTLE_REQUIRED_AGAIN;
				armingSequenceTimeLastStepExecuted = secondsElapsed;

			} else if (armingSequenceStep == ARMING_SEQUENCE_LOW_THROTTLE_REQUIRED_AGAIN && thrust == 0.0) {
				armingSequenceStep = ARMING_SEQUENCE_ARMED;
				armingSequenceTimeLastStepExecuted = secondsElapsed;

				TurnOff(YELLOW_LED);
				TurnOn(BLUE_LED);
			}
		}

		WaitAFewMillis(10);
	}


	/* go go go! */

	uint16_t loopsPerSecond = 0;
	uint32_t thisSecond = 0;

	while(1) {
		loopsPerSecond++;
		ReadAngularPosition();

		float thrust = ReadRemoteThrottle();
		float baseMotorSpeed = 0;
		float motorAdjustment = 0;
		float bMotorSpeed = 0.0;
		float eMotorSpeed = 0.0;
		float cMotorSpeed = 0.0;
		float aMotorSpeed = 0.0;
		float xAdjustment = 0.0;
		float yAdjustment = 0.0;

		if ((armingSequenceStep != ARMING_SEQUENCE_ARMED || ARMING_SEQUENCE_IS_DISABLED) && secondsElapsed > armingSequenceTimeLastStepExecuted) {
			if (armingSequenceStep == ARMING_SEQUENCE_LOW_THROTTLE_REQUIRED && thrust == 0.0) {
				armingSequenceStep = ARMING_SEQUENCE_HIGH_THROTTLE_REQUIRED;
				armingSequenceTimeLastStepExecuted = secondsElapsed;

			} else if (armingSequenceStep == ARMING_SEQUENCE_HIGH_THROTTLE_REQUIRED && thrust == 100.0) {
				armingSequenceStep = ARMING_SEQUENCE_LOW_THROTTLE_REQUIRED_AGAIN;
				armingSequenceTimeLastStepExecuted = secondsElapsed;

			} else if (armingSequenceStep == ARMING_SEQUENCE_LOW_THROTTLE_REQUIRED_AGAIN && thrust == 0.0) {
				armingSequenceStep = ARMING_SEQUENCE_ARMED;
				armingSequenceTimeLastStepExecuted = secondsElapsed;

				TurnOff(YELLOW_LED);
				TurnOn(BLUE_LED);
			}
		} else if (armingSequenceStep == ARMING_SEQUENCE_ARMED) {
			xAdjustment = CalculatePidAdjustment(&xAxisPid, angularPosition.x, 0.0);
			yAdjustment = CalculatePidAdjustment(&yAxisPid, angularPosition.y, 0.0);

			if (xAdjustment < PID_MINIMUM_BOUND) { xAdjustment = PID_MINIMUM_BOUND; }
			if (xAdjustment > PID_MAXIMUM_BOUND) { xAdjustment = PID_MAXIMUM_BOUND; }
			if (yAdjustment < PID_MINIMUM_BOUND) { yAdjustment = PID_MINIMUM_BOUND; }
			if (yAdjustment > PID_MAXIMUM_BOUND) { yAdjustment = PID_MAXIMUM_BOUND; }

			if (thrust == 0.0) {
				/* always turn it off when the throttle is zero, independent of throttle constants */
				bProp.set(1000);
				eProp.set(1000);
				cProp.set(1000);
				aProp.set(1000);
			} else {
				/* throttle is converted to a range of -50 to +50 */
				baseMotorSpeed = MOTOR_SPEED_REQUIRED_FOR_LIFT + (THROTTLE_SENSITIVITY * (thrust - 50.0));

				bMotorSpeed = baseMotorSpeed + yAdjustment;
				eMotorSpeed = baseMotorSpeed - yAdjustment;
				cMotorSpeed = baseMotorSpeed + xAdjustment;
				aMotorSpeed = baseMotorSpeed - xAdjustment;

				/* adjust all motor speeds if one motor is outside motor speed bounds */
				/* this is a deliberate choice to prioritise desired angular position over desired thrust */
				float smallestMotorSpeed = MAXIMUM_MOTOR_SPEED;
				float largestMotorSpeed = MINIMUM_MOTOR_SPEED;

				if (bMotorSpeed < smallestMotorSpeed) { smallestMotorSpeed = bMotorSpeed; }
				if (bMotorSpeed > largestMotorSpeed) { largestMotorSpeed = bMotorSpeed; }
				if (eMotorSpeed < smallestMotorSpeed) { smallestMotorSpeed = eMotorSpeed; }
				if (eMotorSpeed > largestMotorSpeed) { largestMotorSpeed = eMotorSpeed; }
				if (cMotorSpeed < smallestMotorSpeed) { smallestMotorSpeed = cMotorSpeed; }
				if (cMotorSpeed > largestMotorSpeed) { largestMotorSpeed = cMotorSpeed; }
				if (aMotorSpeed < smallestMotorSpeed) { smallestMotorSpeed = aMotorSpeed; }
				if (aMotorSpeed > largestMotorSpeed) { largestMotorSpeed = aMotorSpeed; }

				if (smallestMotorSpeed < MINIMUM_MOTOR_SPEED) {
					motorAdjustment = MINIMUM_MOTOR_SPEED - smallestMotorSpeed;
				} else if (largestMotorSpeed > MAXIMUM_MOTOR_SPEED) {
					motorAdjustment = MAXIMUM_MOTOR_SPEED - largestMotorSpeed;
				}

				/* apply adjusted motor speeds to the motors */
				bMotorSpeed = bMotorSpeed + motorAdjustment;
				eMotorSpeed = eMotorSpeed + motorAdjustment;
				cMotorSpeed = cMotorSpeed + motorAdjustment;
				aMotorSpeed = aMotorSpeed + motorAdjustment;

				bProp.set(bMotorSpeed);
				eProp.set(eMotorSpeed);
				cProp.set(cMotorSpeed);
				aProp.set(aMotorSpeed);
			}
		}

		if (thisSecond != secondsElapsed) {
			uint8_t loopReference = rand() & 0xFF;

			RecordIntegerMetric(METRIC_SECONDS_ELAPSED, loopReference, secondsElapsed);
			RecordIntegerMetric(METRIC_LOOP_FREQUENCY, loopReference, loopsPerSecond);
			RecordFloatMetric(METRIC_GYROSCOPE_X_POSITION, loopReference, gyroscopeReading.x);
			RecordFloatMetric(METRIC_GYROSCOPE_Y_POSITION, loopReference, gyroscopeReading.y);
			RecordFloatMetric(METRIC_GYROSCOPE_Z_POSITION, loopReference, gyroscopeReading.z);
			RecordFloatMetric(METRIC_GYROSCOPE_TEMPERATURE, loopReference, gyroscopeReading.gyroscopeTemperature);
			RecordIntegerMetric(METRIC_GYROSCOPE_SAMPLE_RATE, loopReference, gyroscopeReading.readings);
			RecordFloatMetric(METRIC_PROPELLOR_B_SPEED, loopReference, bMotorSpeed);
			RecordFloatMetric(METRIC_PROPELLOR_E_SPEED, loopReference, eMotorSpeed);
			RecordFloatMetric(METRIC_PROPELLOR_C_SPEED, loopReference, cMotorSpeed);
			RecordFloatMetric(METRIC_PROPELLOR_A_SPEED, loopReference, aMotorSpeed);
			RecordFloatMetric(METRIC_PID_X_ADJUSTMENT, loopReference, xAdjustment);
			RecordFloatMetric(METRIC_PID_Y_ADJUSTMENT, loopReference, yAdjustment);
			RecordFloatMetric(METRIC_REMOTE_PID_PROPORTIONAL, loopReference, xAxisPid.proportional);
			RecordFloatMetric(METRIC_REMOTE_THROTTLE, loopReference, thrust);
			RecordFloatMetric(METRIC_ACCELEROMETER_X_POSITION, loopReference, accelerometerReading.x);
			RecordFloatMetric(METRIC_ACCELEROMETER_Y_POSITION, loopReference, accelerometerReading.y);
			RecordFloatMetric(METRIC_ACCELEROMETER_Z_POSITION, loopReference, accelerometerReading.z);
			RecordIntegerMetric(METRIC_ACCELEROMETER_SAMPLE_RATE, loopReference, accelerometerReading.readings);
			RecordFloatMetric(METRIC_ANGULAR_X_POSITION, loopReference, angularPosition.x);
			RecordFloatMetric(METRIC_ANGULAR_Y_POSITION, loopReference, angularPosition.y);
			RecordFloatMetric(METRIC_ANGULAR_Z_POSITION, loopReference, angularPosition.z);
			RecordIntegerMetric(METRIC_METRICS_BUFFER_SIZE, loopReference, metricsRingBuffer.count);
			RecordFloatMetric(METRIC_DEBUG_VALUE_1, loopReference, baseMotorSpeed);
			RecordFloatMetric(METRIC_DEBUG_VALUE_2, loopReference, motorAdjustment);

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
