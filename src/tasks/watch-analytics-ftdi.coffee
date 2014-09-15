
module.exports = ->
  SerialPort = require('serialport').SerialPort
  through = require 'through2'

  concatenate = (bufferA, bufferB) ->
    newBuffer = new Buffer(bufferA.length + bufferB.length)
    bufferA.copy(newBuffer)
    bufferB.copy(newBuffer, bufferA.length)
    newBuffer

  processData = (data) ->
      name = data.toString('ascii', 0, 9)
      format = data.toString('ascii', 10, 11)

      if format == 'I'
        if data.length == 18
          timeInSeconds = data.readUInt32BE(12)
          value = data.readUInt16BE(16)
          console.log("#{name}: #{timeInSeconds}, #{value}")
        else
          console.log "failed to parse message #{data.toString()} - expected integer messages to be length 18 but was #{data.length}"

      else if format == 'F'
        if data.length == 20
          timeInSeconds = data.readUInt32BE(12)
          value = data.readFloatBE(16)
          console.log("#{name}: #{timeInSeconds}, #{value}")
        else
          console.log "failed to parse message #{data.toString()} - expected float messages to be length 20 but was #{data.length}"
      else
        console.log "failed to parse message #{data.toString()} - unknown format #{format}"

  serialPort = new SerialPort "/dev/cu.usbserial-A9WZZTHD", baudrate: 9600

  serialPort.on "open", ->
    console.log "connected to serial port"

    buffer = new Buffer(0)

    serialPort.on 'data', (data) ->
      stopBit = data.toString().indexOf('|')

      if stopBit != -1
        buffer = concatenate(buffer, data.slice(0, stopBit))
        processData(buffer)
        buffer = data.slice(stopBit + 1)
      else
        buffer = concatenate(buffer, data)

  # return a stream, but never call the callback.
  # this is designed to run forever.
  through.obj(->)
