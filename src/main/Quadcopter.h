
#ifndef Quadcopter_h
#define Quadcopter_h

#include <Servo.h>

class Quadcopter {
    private:
        Servo motorA;

    public:
        void fly();
};

#endif /* Quadcopter_h */