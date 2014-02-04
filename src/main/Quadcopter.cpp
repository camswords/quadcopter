#include <Arduino.h>
#include <Throttle.h>
#include <Motor.h>
#include <GpioPin.h>
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
    Motor *motor = new Motor(A3);
    Throttle* throttle = new Throttle(A0);
    GpioPin *pin13 = new GpioPin(13);

    for (;;) {
        motor->accelerateTo(throttle->read());
        pin13->writeHigh();

        // wait a bit
        delay(200);

        pin13->writeLow();

        // wait a bit
        delay(200);
    }
}