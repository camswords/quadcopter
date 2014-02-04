#include <Throttle.h>

Throttle::Throttle(uint8_t pin) {
    throttlePin = pin;
    pinMode(throttlePin, INPUT);
}

int Throttle::read() {
    return pulseIn(throttlePin, HIGH, 25000);
}