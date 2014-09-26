#ifndef PID_H_
#define PID_H_

#include <stdint.h>


/*
 * Proportional: relating to the present error
 * Integral: relating to the error over time
 * Derivative: relating to the prediction of future errors (based on the current rate of change)
 */
typedef struct Pid {
	uint32_t proportional;
	uint32_t integral;
	uint32_t differential;
	float lastError;
	float cumulativeError;
}Pid;

struct Pid InitialisePid(uint32_t proportional, uint32_t integral, uint32_t differential);

float CalculatePidAdjustment(Pid* pid, float current, float target);

#endif
