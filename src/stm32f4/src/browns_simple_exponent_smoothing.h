#ifndef BROWNS_SIMPLE_EXPONENT_SMOOTHING_H_
#define BROWNS_SIMPLE_EXPONENT_SMOOTHING_H_

typedef struct BrownsSimpleExponentSmoothing {
	float alpha;
	float smoothed;
} BrownsSimpleExponentSmoothing;


float StepBrownsSimpleExponentSmoothing(BrownsSimpleExponentSmoothing* _this, float measurement);

#endif
