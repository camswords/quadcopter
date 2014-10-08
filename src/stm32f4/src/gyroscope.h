
#ifndef GYROSCOPE_H_
#define GYROSCOPE_H_

#include <i2c.h>
#include <stdbool.h>

typedef struct GyroscopeReading {
	float x;
	float y;
	float z;
	float gyroscopeTemperature;
	float xOffset;
	float yOffset;
	float zOffset;
	uint32_t sampleTime;
	float xAngleDriftPerSecond;
	float yAngleDriftPerSecond;
	float zAngleDriftPerSecond;
	bool trustworthy;
}GyroscopeReading;

struct GyroscopeReading gyroscopeReading;

bool InitialiseGyroscope();

void ReadGyroscope();

#endif
