
#ifndef GYROSCOPE_H_
#define GYROSCOPE_H_

#include <i2c.h>

typedef struct GyroscopeReading {
	float x;
	float y;
	float z;
	float gyroscopeTemperature;
}GyroscopeReading;

struct GyroscopeReading CreateGyroscopeReading();

void InitialiseGyroscope();

void ReadGyroscope(struct GyroscopeReading* gyroscopeReading);

#endif
