#include <Rotors.h>

void Rotors() {
}

void Rotors::initialise(uint8_t motorAPin, uint8_t motorBPin, uint8_t motorCPin, uint8_t motorDPin) {
    motorA.attach(motorAPin);
    motorB.attach(motorBPin);
    motorC.attach(motorCPin);
    motorD.attach(motorDPin);
}

void Rotors::throttleTo(int pulseWidth) {
    motorA.writeMicroseconds(pulseWidth);
    motorB.writeMicroseconds(pulseWidth);
    motorC.writeMicroseconds(pulseWidth);
    motorD.writeMicroseconds(pulseWidth);
}