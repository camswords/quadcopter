#ifndef REMOTE_CONTROLS_H_
#define REMOTE_CONTROLS_H_

#include <stdint.h>
#include <pwm_input.h>

struct PWMInput* throttle;

struct PWMInput* xPidProportional;

struct PWMInput* yPidProportional;

struct PWMInput* resetAngularPosition;

void InitialiseRemoteControls();

/* These will come back as a percentage */
float ReadRemoteThrottle();

float ReadRemoteXPidProportional();

float ReadRemoteYPidProportional();

float ReadResetAngularPosition();



#endif
