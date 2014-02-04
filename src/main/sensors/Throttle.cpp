#include <Throttle.h>

Throttle::Throttle(uint8_t pin) {
    pinMode(pin, INPUT);
}

int Throttle::read() {
    return pulseIn(A0, HIGH, 25000);
}