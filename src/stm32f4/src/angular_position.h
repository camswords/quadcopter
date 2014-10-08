#ifndef ANGULAR_POSITION_H_
#define ANGULAR_POSITION_H_

#include <systick.h>
#include <stdbool.h>

typedef struct AngularPosition {
	float x;
	float y;
	float z;
	bool trustworthy;
}AngularPosition;

struct AngularPosition angularPosition;

void InitialiseAngularPosition();

void ReadAngularPosition();

void ResetToAngularZeroPosition();

#endif
