
#ifndef GpioPin_h
#define GpioPin_h

#include <Arduino.h>

class GpioPin {
private:
    uint8_t pin;
    
public:
    GpioPin(uint8_t pin);
    void writeHigh();
    void writeLow();
};

#endif /* GpioPin_h */
