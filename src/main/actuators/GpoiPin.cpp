
#include <GpioPin.h>

GpioPin::GpioPin(uint8_t pinNumber) {
    pin = pinNumber;
}

void GpioPin::writeHigh() {
    pinMode(pin, OUTPUT);
    digitalWrite(pin, HIGH);
}

void GpioPin::writeLow() {
    pinMode(pin, OUTPUT);
    digitalWrite(pin, LOW);
}