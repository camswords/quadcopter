
#ifndef GYROSCOPE_H_
#define GYROSCOPE_H_

#include <i2c.h>

typedef struct GyroscopeReading {
	int16_t x;
	int16_t y;
	int16_t z;
	int16_t gyroscopeTemperature;
}GyroscopeReading;

struct GyroscopeReading CreateGyroscopeReading();

void InitialiseGyroscope();

void ReadGyroscope(struct GyroscopeReading* gyroscopeReading);

#endif
