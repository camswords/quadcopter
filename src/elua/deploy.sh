#!/usr/bin/env bash

set -e

# remove lua files from a previous build
rm -f $ELUA_BUILD_DIRECTORY/romfs/*.lua

# copy files to ROM directory, these end up being readonly files on the microcontroller
cp -r *.lua $ELUA_BUILD_DIRECTORY/romfs/

# build the elf file from the elua source
cd $ELUA_BUILD_DIRECTORY
build_elua.lua board=stm32f4discovery

# convert the elf file to a bin file ready for upload
arm-none-eabi-objcopy -O binary ./elua_lua_stm32f4discovery.elf ./elua_lua_stm32f4discovery.bin

# upload the file to the usb connected board. Please ensure your board is setup in bootloader mode
dfu-util --device 0483:df11 --cfg 1 --intf 0 --alt 0 --dfuse-address 0x08000000 --download elua_lua_stm32f4discovery.bin
