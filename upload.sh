#!/bin/bash

# Run the scons compile script
ARDUINO_BOARD=yun ARSCONS_TARGET=quadcopter scons -f src/build/SConstruct 

# deploy the code using the Arduino Yun linino
scp scripts/deploy.sh root@tw.quadcopter:~
scp build/quadcopter.hex root@tw.quadcopter:~
ssh root@tw.quadcopter 'chmod 755 ~/deploy.sh; ~/deploy.sh'

# remove all .o files that were (annoyingly) compiled into the src directory
rm -rf src/main/*.o

# remove the db for scons
rm -f .sconsign.dblite