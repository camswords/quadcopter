
#include <angular_position.h>
#include <gyroscope.h>
#include <accelerometer.h>
#include <magnetometer.h>

void InitialiseAngularPosition() {
	/* initialise, assume the quad is level */
	angularPosition.x = 0.0;
	angularPosition.y = 0.0;
	angularPosition.z = 0.0;

	InitialiseGyroscope();
	InitialiseAccelerometer();
	InitialiseMagnetometer();
}

void ReadAngularPosition() {
	ReadGyroscope(&gyroscopeReading);
	ReadAccelerometer(&accelerometerReading);
	ReadMagnetometer(&magnetometerReading);
}

