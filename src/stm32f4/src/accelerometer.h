
#ifndef ACCELEROMETER_H
#define ACCELEROMETER_H

#include <i2c.h>

bool isReadingAccelerometer;

typedef struct AccelerometerReading {
	float x;
	float y;
	float z;
	float xOffset;
	float yOffset;
	float zOffset;
	uint32_t readings;
}AccelerometerReading;

struct AccelerometerReading accelerometerReading;

void InitialiseAccelerometer();

void ReadAccelerometer();

#endif
