#ifndef REMOTE_CONTROLS_H_
#define REMOTE_CONTROLS_H_

#include <stdint.h>
#include <pwm_input.h>
#include <browns_simple_exponent_smoothing.h>

struct PWMInput* throttle;
BrownsSimpleExponentSmoothing smoothedThrottle;

struct PWMInput* rudder;
BrownsSimpleExponentSmoothing smoothedRudder;

struct PWMInput* pidProportional;
BrownsSimpleExponentSmoothing smoothedPidProportional;

struct PWMInput* resetAngularPosition;
BrownsSimpleExponentSmoothing smoothedResetAngularPosition;

void InitialiseRemoteControls();

/* These will come back as a percentage */
float ReadRemoteThrottle();

float ReadRemoteRudder();

float ReadRemotePidProportional();

float ReadResetAngularPosition();



#endif
