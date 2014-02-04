#include <Arduino.h>
#include <Throttle.h>
#include <Quadcopter.h>

int main(void) {
    init();

    #if defined(USBCON)
        USBDevice.attach();
    #endif

    Quadcopter *quadcopter = new Quadcopter();
    quadcopter->fly();
        
    return 0;
}

void Quadcopter::fly() {
    motorA.attach(A3);

    Throttle* throttle = new Throttle(A0);

    for (;;) {
        motorA.writeMicroseconds(throttle->read());

        // wait a bit
        delay(100);
    }
}