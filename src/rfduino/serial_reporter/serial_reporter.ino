#include <RFduinoBLE.h>

char data[1000];
int connected = false;

void setup() {
  /* RX is Pin 0, TX is Pin 1 */
  Serial.begin(9600, 0, 1);
  RFduinoBLE.begin();
}

void RFduinoBLE_onConnect() {
  connected = true;
}

void loop() {

  /* Wait while the Radio is active */
  while (RFduinoBLE.radioActive)
  ;
  
  /* Quick! Give me the data! */
  Serial.write(1);
  char bytesRead = 0;
  
  /* Read in 100 bytes of data */
  while(bytesRead < 1000 && (bytesRead == 0 || data[bytesRead - 1] != '|')) {
    if (Serial.available()) {
      char characterRead = Serial.read();
      data[bytesRead++] = characterRead;
    }
      
    /* best not to thrash */
    delay(5);
 }

  if (connected) {
    /* send is queued (the ble stack delays send to the start of the next tx window) */
    while (! RFduinoBLE.send(data, bytesRead))
      ;  /* all tx buffers in use (can't send - try again later) */
  }
}

