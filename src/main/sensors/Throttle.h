
#ifndef Throttle_h
#define Throttle_h

#include <Arduino.h>

class Throttle {

public:
    Throttle(uint8_t pin);
    int read();
};

#endif /* Throttle_h */