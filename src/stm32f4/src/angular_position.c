
#include <angular_position.h>
#include <gyroscope.h>
#include <accelerometer.h>
#include <magnetometer.h>
#include <stm32f4xx_it.h>
#include <delay.h>
#include <configuration.h>

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

//  seems buggered. will introduce the gyro later.
//	angularPosition.x = HOW_MUCH_I_TRUST_THE_GYROSCOPE * (angularPosition.x + (gyroscopeReading.x * GYROSCOPE_SAMPLE_RATE)) + HOW_MUCH_I_TRUST_THE_ACCELEROMETER * accelerometerReading.x;
//	angularPosition.y = HOW_MUCH_I_TRUST_THE_GYROSCOPE * (angularPosition.y + (gyroscopeReading.y * GYROSCOPE_SAMPLE_RATE)) + HOW_MUCH_I_TRUST_THE_ACCELEROMETER * accelerometerReading.y;
//	angularPosition.z = 0;

	angularPosition.x = accelerometerReading.x;
	angularPosition.y = accelerometerReading.y;
	angularPosition.z = accelerometerReading.z;
}

void ResetToAngularZeroPosition() {
	angularPosition.x = 0.0;
	angularPosition.y = 0.0;
	angularPosition.z = 0.0;
}

