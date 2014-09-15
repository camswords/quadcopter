
#ifndef MAGNETOMETER_H_
#define MAGNETOMETER_H_

#include <i2c.h>

typedef struct MagnetometerReading {
	int16_t x;
	int16_t y;
	int16_t z;
}MagnetometerReading;

struct MagnetometerReading magnetometerReading;

void InitialiseMagnetometer();

void ReadMagnetometer();

#endif
