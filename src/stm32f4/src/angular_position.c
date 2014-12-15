
#include <angular_position.h>
#include <gyroscope.h>
#include <accelerometer.h>
#include <magnetometer.h>
#include <stm32f4xx_it.h>
#include <delay.h>

/* are my angles consistent - radians, or degrees? */

void InitialiseAngularPosition() {
	/* initialise, assume the quad is level */
	angularPosition.x = 0.0;
	angularPosition.y = 0.0;
	angularPosition.z = 0.0;

	sensorToggle = true;

	InitialiseGyroscope();
	InitialiseAccelerometer();
	//InitialiseMagnetometer();
}

void ReadAngularPosition() {

	if (i2cHasProblem) {
		isReadingAccelerometer = false;
		isReadingGyroscope = false;
		ResetI2C();
		InitialiseI2C();
		return;
	}

	if (sensorToggle) {
		/* this gryo is dodgy. Sometimes, the last bit in the read sequence never comes back properly, causing errors on the I2C bus. Silly gyro. */
		ReadGyroscope();

		if (!isReadingGyroscope) {
			sensorToggle = !sensorToggle;
		}
	} else {
		ReadAccelerometer();

		if (!isReadingAccelerometer) {
			sensorToggle = !sensorToggle;
		}
	}

	// ReadMagnetometer();

	/* welcome to the complimentary filter */
	const float highFrequencyImportance = 0.98f;

	/* the dt in the calculation. Note that it roughly gets a reading every millisecond */
	/* this is a bit of a lie: sample rate is closer to 1.74k per second now that the gyro calculations are simpler. */
	const float sampleRate = 1.0f / (1000.0f / 1.0f);

	angularPosition.x = highFrequencyImportance * (angularPosition.x + (gyroscopeReading.x * sampleRate)) + (1.0f - highFrequencyImportance) * accelerometerReading.x;
	angularPosition.y = highFrequencyImportance * (angularPosition.y + (gyroscopeReading.y * sampleRate)) + (1.0f - highFrequencyImportance) * accelerometerReading.y;
	angularPosition.z = 0;
}

void ResetToAngularZeroPosition() {
	angularPosition.x = 0.0;
	angularPosition.y = 0.0;
	angularPosition.z = 0.0;
}

