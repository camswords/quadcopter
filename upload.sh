#!/bin/bash

function fail_if_error {
    if [ $? -ne 0 ]; then
        echo
        echo $1
        echo
        exit 1    
    fi
}

# compile the quadcopter source code
./compile.sh
fail_if_error "Please fix compilation errors before uploading."

# deploy the code using the Arduino Yun linino
scp src/build/deploy.sh root@tw.quadcopter:~
fail_if_error "Failed to copy deploy script to Arduino, aborting."

scp build/quadcopter.hex root@tw.quadcopter:~
fail_if_error "Failed to copy quadcopter binary to Arduino, aborting."

ssh root@tw.quadcopter 'chmod 755 ~/deploy.sh; ~/deploy.sh'
fail_if_error "Failed to deploy quadcopter binary on Arduino, aborting."