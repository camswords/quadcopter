
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
	angularPosition.x += gyroscopeReading.x;
	angularPosition.y += gyroscopeReading.y;
	angularPosition.z += gyroscopeReading.z;
}

void ResetToAngularZeroPosition() {
	angularPosition.x = 0.0;
	angularPosition.y = 0.0;
	angularPosition.z = 0.0;
}

