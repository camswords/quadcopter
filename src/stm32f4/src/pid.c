
#include <pid.h>

struct Pid InitialisePid(float proportional, float integral, float differential) {
	Pid pid;

	pid.proportional = proportional;
	pid.integral = integral;
	pid.differential = differential;
	pid.lastError = 0.0;
	pid.cumulativeError = 0.0;

	return pid;
}

float CalculatePidAdjustment(Pid* pid, float current, float target) {
    float error = target - current;
    float diff = error - pid->lastError;
    pid->lastError = error;
    pid->cumulativeError += error;

    return (pid->proportional * error) +
           (pid->integral * pid->cumulativeError) +
           (pid->differential * diff);
}
