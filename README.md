The ThoughtWorks Sydney Quadcopter
==========

The ThoughtWorks Sydney Quadcopter is a quadcopter that is being built by the ThoughtWorks Sydney Community. 

To find out parts we have used, lessons we have learnt check out http://www.camswords.com/blog. To see photos of the quadcopter as it is built check out http://www.pinterest.com/camswords/the-thoughtworks-sydney-maker-day.

Prerequisites
------------

This software is designed to run on an Arduino that works as the brain of a quadcopter. To use this software for your own quadcopter, you will need all of the electronic parts that make up a quadcopter.

This software is written tailored to the hardware we're using. For example, the  script that uploads to the Arduino microcontroller assumes you are using an Arduino Yún. You can find out what parts we used on the blog.


Installation Instructions
------------
1. Install the Arduino IDE from http://arduino.cc/en/Main/Software. This software has been tested using Arduino 1.5.5 on Mac OSX.
2. Get the source code from github: 
```
git clone git@github.com:camswords/quadcopter.git
```
3. You will need to have python installed on your machine
4. You will need to have the pyserial library installed on your machine ```pip install pyserial```
5. You will need to have the python build tool scons installed on your machine.


Changing the source code
------------
Once you have installed the software on your computer, you can start editing and compiling the source code.

All of the quadcopter source code resides under the ```src/main``` directory. Build scripts reside under the ```src/build``` directory.

As you make changes to the code you will need to recompile the code into a hex file that the Arduino can understand. You can do this by running the ```compile.sh``` script located in the root directory.

As you write code that depends on Arduino libraries you will need to ensure the library is also compiled into the hex file. You can do this by adding the name of the library to the ```INCLUDE_LIBRARIES``` environment variable defined in the compile.sh script.


Uploading changes to the Arduino
------------
To upload updated source code to the Arduino you will need to:

1. Ensure that you can log into the Linino operating system on your Yún as the root user. You must set up an authorized key as the upload script does not specify a password.

2. The Arduino Linino operating system must be connected to the same network that your computer is connected to. The script locates the Arduino using the name ```tw.quadcopter```. If you know the IP Address of your Arduino then you can register this in your local /etc/hosts file.

3. Run ```./upload.sh``` to recompile your source code, upload the hex file and deploy script to the Linino operating system and then trigger a deploy which will flash the hex file on to the Arduino Microprocessor.