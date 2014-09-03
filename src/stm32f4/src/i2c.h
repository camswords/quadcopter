
#ifndef I2C_H
#define I2C_H

#include <stdint.h>

typedef struct AngularPosition {
	int16_t x;
	int16_t y;
	int16_t z;
	int16_t gyroscopeTemperature;
}AngularPosition;

struct AngularPosition CreateInitialAngularPosition();
void InitialiseI2C();
void InitialiseGyroscope();
void ReadGyroscopeValues(struct AngularPosition* angularPosition);

#endif
