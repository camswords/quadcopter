#include <Motor.h>

Motor::Motor(uint8_t pin) {
    servo.attach(pin);    
}

int Motor::accelerateTo(int speed) {
    servo.writeMicroseconds(speed);
}