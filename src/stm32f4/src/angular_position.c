
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

	/* note: make sure that the gyro xyz and accel. xyz match up to the same physical axis */
	/* remember to convert accl. to degrees */
	angularPosition.x = accelerometerReading.x;
	angularPosition.y = accelerometerReading.y;
	angularPosition.z = accelerometerReading.z;
}

void ResetToAngularZeroPosition() {
	angularPosition.x = 0.0;
	angularPosition.y = 0.0;
	angularPosition.z = 0.0;
}

