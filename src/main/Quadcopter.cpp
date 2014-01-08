#include <Arduino.h>
#include <Servo.h>
#include <Rotors.h>
#include <Throttle.h>

int main(void) {
    init();

    #if defined(USBCON)
        USBDevice.attach();
    #endif

    Rotors* rotors = (Rotors*) malloc(sizeof(Rotors));
    rotors->initialise(A3, A4, A5, A6);

    Throttle* throttle = (Throttle*) malloc(sizeof(Throttle));
    throttle->attachToPin(A0);

    Serial.begin(9600);

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
        
    return 0;
}