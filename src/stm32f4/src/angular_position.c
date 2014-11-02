
#include <angular_position.h>
#include <gyroscope.h>
#include <accelerometer.h>
#include <magnetometer.h>
#include <stm32f4xx_it.h>

/* are my angles consistent - radians, or degrees? */

void InitialiseAngularPosition() {
	/* initialise, assume the quad is level */
	angularPosition.x = 0.0;
	angularPosition.y = 0.0;
	angularPosition.z = 0.0;

	InitialiseGyroscope();

	/* turn off until we need to use them */
	InitialiseAccelerometer();
	//InitialiseMagnetometer();
}

void ReadAngularPosition() {
	ReadGyroscope();
	ReadAccelerometer();
	// ReadMagnetometer();

	/* note: make sure that the gyro xyz and accel. xyz match up to the same physical axis */
	/* remember to convert accl. to degrees */
	float gyroToAccelRatio = 0.0f;

	angularPosition.x = (gyroToAccelRatio * gyroscopeReading.x) + ((1.0f - gyroToAccelRatio) * accelerometerReading.x);
	angularPosition.y = (gyroToAccelRatio * gyroscopeReading.y) + ((1.0f - gyroToAccelRatio) * accelerometerReading.y);
	angularPosition.z = (gyroToAccelRatio * gyroscopeReading.z) + ((1.0f - gyroToAccelRatio) * accelerometerReading.z);
}

void ResetToAngularZeroPosition() {
	angularPosition.x = 0.0;
	angularPosition.y = 0.0;
	angularPosition.z = 0.0;
}

