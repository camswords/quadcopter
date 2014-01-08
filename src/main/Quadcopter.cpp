#include <Arduino.h>
#include <Servo.h>
#include <Rotors.h>

typedef Rotors Roto;

int main(void) {
    init();

    #if defined(USBCON)
        USBDevice.attach();
    #endif

    Rotors* rotors = (Rotors*) malloc(sizeof(Rotors));
    rotors->initialise(A3, A4, A5, A6);

    Serial.begin(9600);

    int iteration = 0;
    
    // Input from the RC receiver (throttle channel)
    pinMode(A0, INPUT);
    
    for (;;) {
        iteration = iteration + 1;

        // Read the pulse width from the RC receiver
        int throttle = pulseIn(A0, HIGH, 25000);

        rotors->throttleTo(throttle);

        // Wait a bit, to ensure that any serial connections get a chance to run
        delay(100);

        Serial.print("iteration: ");
        Serial.println(iteration);
    }

    free(rotors);
    rotors = 0;
        
    return 0;
}