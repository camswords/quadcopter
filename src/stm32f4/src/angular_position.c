
#include <angular_position.h>
#include <gyroscope.h>
#include <accelerometer.h>
#include <magnetometer.h>
#include <on_board_leds.h>
#include <delay.h>
#include <stm32f4xx_it.h>


void InitialiseAngularPosition() {
	/* initialise, assume the quad is level */
	angularPosition.x = 0.0;
	angularPosition.y = 0.0;
	angularPosition.z = 0.0;
	angularPosition.trustworthy = true;

	while(!InitialiseGyroscope()) {
		TurnOn(ORANGE_LED);

		WaitAFewMillis(500);

		TurnOff(ORANGE_LED);
	}

	/* turn these off until we need them */
//	InitialiseAccelerometer();
//	InitialiseMagnetometer();
}

void ReadAngularPosition() {
	/* we will always have a sample time here, as it is first set in the initialisation of the gyro */
	uint32_t previousSampleTime = gyroscopeReading.sampleTime;
	angularPosition.trustworthy = true;

	ReadGyroscope();

	/* if not trustworthy, just return.
	 * Note this will probably introduce more gyro error when these problems actually occur.
	 */
	if (!gyroscopeReading.trustworthy) {
		angularPosition.trustworthy = false;
		return;
	}

//	ReadAccelerometer();
//	ReadMagnetometer();

	uint32_t sampleTime = (gyroscopeReading.sampleTime - previousSampleTime);

	/* if we get here, we're going too fast (or something spectacular has gone wrong).
	 * Skip, it will sort it self out for the next time.
	 * Hiding errors like this is a terrible idea. Totes need to understand the root cause of this issue. */
	if (sampleTime > 0  && sampleTime < 1000) {
		float sampleRateHz = 1000.0 / sampleTime;
		float sampleTimeInSeconds = sampleTime / 1000.0;
		angularPosition.x += gyroscopeReading.x / sampleRateHz + (sampleTimeInSeconds * gyroscopeReading.xAngleDriftPerSecond);
		angularPosition.y += gyroscopeReading.y / sampleRateHz + (sampleTimeInSeconds * gyroscopeReading.yAngleDriftPerSecond);
		angularPosition.z += gyroscopeReading.z / sampleRateHz + (sampleTimeInSeconds * gyroscopeReading.zAngleDriftPerSecond);
	}
}

void ResetToAngularZeroPosition() {
	angularPosition.x = 0.0;
	angularPosition.y = 0.0;
	angularPosition.z = 0.0;
}

