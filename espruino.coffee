Q = require 'q'
SerialPort = require('serialport').SerialPort

sendToSerial = (message) ->
  written = Q.defer()
  read = ''

  finalise = ->
    written.resolve(read)
    serialPort.close()

  serialPort = new SerialPort('/dev/tty.usbmodem1421', { baudrate: 9600 }, false)

  serialPort.on 'error', (error) -> written.reject(error)

  serialPort.on 'data', (data) ->
    read += data.toString()

  serialPort.open ->
    serialPort.write message, (error) ->
      if error
        written.reject(error)
      else
        serialPort.drain -> setTimeout(finalise, 1000)

  written.promise

module.exports =
  reset: -> sendToSerial('reset();\n')

