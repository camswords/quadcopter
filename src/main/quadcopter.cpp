#include <Arduino.h>
#include <Servo.h>

int main(void)
{
    init();

    #if defined(USBCON)
        USBDevice.attach();
    #endif
    
    pinMode(13, OUTPUT);
    
    for (;;) {
        digitalWrite(13, HIGH);
        delay(1000);
        digitalWrite(13, LOW);
        delay(200);

        if (serialEventRun) serialEventRun();
    }
        
    return 0;
}