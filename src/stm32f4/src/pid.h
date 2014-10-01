#ifndef PID_H_
#define PID_H_

#include <stdint.h>


/*
 * Proportional: relating to the present error
 * Integral: relating to the error over time
 * Derivative: relating to the prediction of future errors (based on the current rate of change)
 */
typedef struct Pid {
	float proportional;
	float integral;
	float differential;
	float lastError;
	float cumulativeError;
}Pid;

struct Pid InitialisePid(float proportional, float integral, float differential);

float CalculatePidAdjustment(Pid* pid, float current, float target);

#endif
