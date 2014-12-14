#ifndef ANGULAR_POSITION_H_
#define ANGULAR_POSITION_H_

#include <systick.h>
#include <stdbool.h>

bool sensorToggle;

typedef struct AngularPosition {
	float x;
	float y;
	float z;
}AngularPosition;

struct AngularPosition angularPosition;

void InitialiseAngularPosition();

void ReadAngularPosition();

void ResetToAngularZeroPosition();

#endif
