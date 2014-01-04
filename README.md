The ThoughtWorks Sydney Quadcopter
==========


Installation Instructions
------------
1. Install the Arduino IDE from http://arduino.cc/en/Main/Software. This software has been tested using Arduino 1.5.4.
2. Install the source code from github: 
```
git clone git@github.com:camswords/quadcopter.git
```
3. Open the makefile. Follow the instructions at the top of the file and make sure that INSTALL_DIR, ARDUINO, AVR_TOOLS_PATH, and AVRDUDE_PATH point to directories on your system where Arduino has installed its tools and libraries.

4. Still in the makefile, change the PORT, MCU, and ARDUINO_VARIANTS to reflect the Arduino you are using and the port on which it is installed. You can find out more about configuration required for your specific Arduino by looking in the ```boards.txt``` file located in your Arduino installation folder. 

5. Test your installation / configuration by running ```make```. If you get an ```wiring.c:113: undefined reference to `yield'``` error, please comment out the yield reference in the Arduino wiring.c library. I am still to properly work out what files to include / exclude when compiling Arduino libraries.

Usage
-----------
```make```: this will compile the quadcopter source code into a hex file.

```make upload```: this will compile and upload the quadcopter code onto your Arduino.

