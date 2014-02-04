
#ifndef Motor_h
#define Motor_h

#include <Servo.h>

class Motor {
private:
    Servo servo;

public:
    Motor(uint8_t pin);
    int accelerateTo(int speed);
};

#endif /* Motor_h */
