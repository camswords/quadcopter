
#ifndef GYROSCOPE_H_
#define GYROSCOPE_H_

#include <i2c.h>
#include <stdint.h>

bool isReadingGyroscope;

typedef struct GyroscopeReading {
	float x;
	float y;
	float z;
	int16_t rawX;
	int16_t rawY;
	int16_t rawZ;
	float gyroscopeTemperature;
	float xOffset;
	float yOffset;
	float zOffset;
	uint32_t readings;
}GyroscopeReading;

struct GyroscopeReading gyroscopeReading;

void InitialiseGyroscope();

void ReadGyroscope();

#endif
