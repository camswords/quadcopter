#include <browns_simple_exponent_smoothing.h>

float StepBrownsSimpleExponentSmoothing(BrownsSimpleExponentSmoothing* _this, float measurement) {
	_this->smoothed = _this->alpha * measurement + (1 - _this->alpha) * _this->smoothed;
	return _this->smoothed;
}
