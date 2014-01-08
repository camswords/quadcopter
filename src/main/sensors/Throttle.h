
#ifndef Throttle_h
#define Throttle_h

#include <Arduino.h>

class Throttle {

public:
    void attachToPin(uint8_t pin);
    int read();
};

#endif /* Throttle_h */