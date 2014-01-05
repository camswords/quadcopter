#include <Arduino.h>
#include <Servo.h>

int main(void) {
    init();

    #if defined(USBCON)
        USBDevice.attach();
    #endif

    Servo motorA;
    Servo motorB;
    Servo motorC;
    Servo motorD;
    
    int iteration = 0;
    
    // Input from the RC receiver (throttle channel)
    pinMode(A0, INPUT);
    
    // Output throttle values for each of the motors
    motorA.attach(A3);
    motorB.attach(A4);
    motorC.attach(A5);
    motorD.attach(A6);

    Serial.begin(9600);

    for (;;) {
        iteration = iteration + 1;

        // Read the pulse width from the RC receiver
        int throttle = pulseIn(A0, HIGH, 25000); 

        // Write the same throttle to all of the motors
        motorA.writeMicroseconds(throttle);
        motorB.writeMicroseconds(throttle);
        motorC.writeMicroseconds(throttle);
        motorD.writeMicroseconds(throttle);
        
        // Wait a bit, to ensure that any serial connections get a chance to run
        delay(100);

        Serial.print("iteration: ");
        Serial.println(iteration);
    }
        
    return 0;
}