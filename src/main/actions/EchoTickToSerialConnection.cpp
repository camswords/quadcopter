#include <EchoTickToSerialConnection.h>
#include <Arduino.h>

void EchoTickToSerialConnection::execute(long tickNumber) {
    Serial.print("tick: ");
    Serial.println(tickNumber);
}