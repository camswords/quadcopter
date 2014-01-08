#include <Arduino.h>
#include <Rotors.h>
#include <Throttle.h>
#include <Quadcopter.h>
#include <EventLoop.h>

int main(void) {
    init();

    #if defined(USBCON)
        USBDevice.attach();
    #endif

    Serial.begin(9600);

    Quadcopter::fly();
        
    return 0;
}


void Quadcopter::fly() {
    Rotors* rotors = (Rotors*) malloc(sizeof(Rotors));
    rotors->initialise(A3, A4, A5, A6);

    Throttle* throttle = (Throttle*) malloc(sizeof(Throttle));
    throttle->attachToPin(A0);

    EventLoop* eventLoop = (EventLoop*) malloc(sizeof(EventLoop));
    eventLoop->run();

    int iteration = 0;
    
    for (;;) {
        iteration = iteration + 1;

        rotors->throttleTo(throttle->read());

        // Wait a bit, to ensure that any serial connections get a chance to run
        delay(100);

        Serial.print("iteration: ");
        Serial.println(iteration);
    }

    free(rotors);
    rotors = 0;

    free(throttle);
    throttle = 0;

    free(eventLoop);
    eventLoop = 0;
}