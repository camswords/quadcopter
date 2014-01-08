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
ARDUINO_BOARD=yun ARSCONS_TARGET=quadcopter INCLUDE_LIBRARIES=Servo,Bridge scons -f src/build/SConstruct 
fail_if_error "Compilation failed, aborting."

# remove all .o files that were (annoyingly) compiled into the src directory
find src/main -name *.o -exec rm {} ';'

# remove the db for scons
rm -f .sconsign.dblite
