
#ifndef ACCELEROMETER_H
#define ACCELEROMETER_H

#include <i2c.h>

typedef struct AccelerometerReading {

}AccelerometerReading;

struct AccelerometerReading CreateAccelerometerReading();

void InitialiseAccelerometer();

void ReadAccelerometer(struct AccelerometerReading* accelerometerReading);



#endif
