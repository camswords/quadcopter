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

    Quadcopter* quadcopter = new Quadcopter();
    quadcopter->fly();
        
    return 0;
}

void Quadcopter::fly() {
    Motor* motorA = new Motor(A2);
    Motor* motorB = new Motor(A3);
    Motor* motorC = new Motor(A4);
    Motor* motorD = new Motor(A5);

    Throttle* throttle = new Throttle(A0);

    for (;;) {
        int speed = throttle->read();

        motorA->accelerateTo(speed);
        motorB->accelerateTo(speed);
        motorC->accelerateTo(speed);
        motorD->accelerateTo(speed);

        delay(200);
    }
}