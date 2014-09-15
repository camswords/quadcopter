#ifndef ANGULAR_POSITION_H_
#define ANGULAR_POSITION_H_

#include <systick.h>

typedef struct AngularPosition {
	float x;
	float y;
	float z;
}AngularPosition;

struct AngularPosition angularPosition;

void InitialiseAngularPosition();

void ReadAngularPosition();

#endif
