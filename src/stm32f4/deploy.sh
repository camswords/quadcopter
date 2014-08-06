#!/usr/bin/env bash

set -e
make clean all

# upload the file to the usb connected board. Please ensure your board is setup in bootloader mode
dfu-util --device 0483:df11 --cfg 1 --intf 0 --alt 0 --dfuse-address 0x08000000 --download build/quadcopter.bin
