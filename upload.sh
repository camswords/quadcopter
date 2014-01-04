#!/bin/bash

function fail_if_error {
    if [ $? -ne 0 ]; then
        echo
        echo $1
        echo
        exit 1    
    fi
}

# Recreate the build directory
rm -rf build
mkdir build

# Run the scons compile script
ARDUINO_BOARD=yun ARSCONS_TARGET=quadcopter scons -f src/build/SConstruct 
fail_if_error "Compilation failed, aborting."

# deploy the code using the Arduino Yun linino
scp src/build/deploy.sh root@tw.quadcopter:~
fail_if_error "Failed to copy deploy script to Arduino, aborting."

scp build/quadcopter.hex root@tw.quadcopter:~
fail_if_error "Failed to copy quadcopter binary to Arduino, aborting."

ssh root@tw.quadcopter 'chmod 755 ~/deploy.sh; ~/deploy.sh'
fail_if_error "Failed to deploy quadcopter binary on Arduino, aborting."

# remove all .o files that were (annoyingly) compiled into the src directory
rm -rf src/main/*.o

# remove the db for scons
rm -f .sconsign.dblite