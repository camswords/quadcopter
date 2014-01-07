#include <Arduino.h>
#include <Servo.h>
#include <Process.h>

int main(void) {
    init();

    #if defined(USBCON)
        USBDevice.attach();
    #endif

    Serial.begin(9600);
    Bridge.begin();

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

        Process p;        // Create a process and call it "p"
        p.begin("curl");  // Process that launch the "curl" command
        p.addParameter("http://arduino.cc/asciilogo.txt"); // Add the URL parameter to "curl"
        p.run();      // Run the process and wait for its termination

        while (p.available()>0) {
            char c = p.read();
            Serial.print(c);
        }

        Serial.flush();
    }
        
    return 0;
}