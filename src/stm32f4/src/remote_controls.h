#ifndef REMOTE_CONTROLS_H_
#define REMOTE_CONTROLS_H_

#include <stdint.h>
#include <pwm_input.h>

struct PWMInput* throttle;

struct PWMInput* remotePidProportional;

struct PWMInput* remotePidIntegral;

struct PWMInput* resetAngularPosition;

void InitialiseRemoteControls();

/* These will come back as a percentage */
float ReadRemoteThrottle();

float ReadRemotePidProportional();

float ReadRemotePidIntegral();

float ReadResetAngularPosition();



#endif
