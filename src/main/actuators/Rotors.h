
#ifndef Rotors_h
#define Rotors_h

#include <Servo.h>

class Rotors {
private:
    Servo motorA;
    Servo motorB;
    Servo motorC;
    Servo motorD;

public:
    void initialise(uint8_t motorAPin, uint8_t motorBPin, uint8_t motorCPin, uint8_t motorDPin);
    void throttleTo(int pulseWidth);
};

#endif /* Rotors_h */