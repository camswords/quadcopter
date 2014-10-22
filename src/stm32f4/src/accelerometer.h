
#ifndef ACCELEROMETER_H
#define ACCELEROMETER_H

#include <i2c.h>

typedef struct AccelerometerReading {
	float x;
	float y;
	float z;
	float xOffset;
	float yOffset;
	float zOffset;
}AccelerometerReading;

struct AccelerometerReading accelerometerReading;

void InitialiseAccelerometer();

void ReadAccelerometer();

#endif
