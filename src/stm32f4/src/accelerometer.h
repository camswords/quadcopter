
#ifndef ACCELEROMETER_H
#define ACCELEROMETER_H

#include <i2c.h>

typedef struct AccelerometerReading {
	int16_t x;
	int16_t y;
	int16_t z;
}AccelerometerReading;

struct AccelerometerReading CreateAccelerometerReading();

void InitialiseAccelerometer();

void ReadAccelerometer(struct AccelerometerReading* accelerometerReading);

#endif
