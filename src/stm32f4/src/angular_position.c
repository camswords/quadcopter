
#include <angular_position.h>
#include <gyroscope.h>
#include <accelerometer.h>
#include <magnetometer.h>
#include <stm32f4xx_it.h>

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
	/* we will always have a sample time here, as it is first set in the initialisation of the gyro */
	uint32_t previousSampleTime = gyroscopeReading.sampleTime;

	ReadGyroscope();
	ReadAccelerometer();
	ReadMagnetometer();

	uint32_t sampleTime = (gyroscopeReading.sampleTime - previousSampleTime);

	/* hmm we have issues if ever we get here. die! */
	if (sampleTime < 0 || sampleTime == 0 || sampleTime > 1000) {
		HardFault_Handler();
	}

	float sampleRateHz = 1000.0 / (gyroscopeReading.sampleTime - previousSampleTime);
	angularPosition.x += gyroscopeReading.x / sampleRateHz;
	angularPosition.y += gyroscopeReading.y / sampleRateHz;
	angularPosition.z += gyroscopeReading.z / sampleRateHz;
}

