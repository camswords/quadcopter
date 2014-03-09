Q = require 'q'
SerialPort = require('serialport').SerialPort
config = require '../configuration'

sendToSerial = (message) ->
  written = Q.defer()
  read = ''

  finalise = ->
    written.resolve(read)
    serialPort.close()

  serialPort = new SerialPort(config.espruino.serialPort, { baudrate: 9600 }, false)

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

espruino =
  reset: -> sendToSerial('reset();\n')
  upload: (code) -> sendToSerial("{ #{code} }\n")

module.exports =
  deploy: (code) ->
    deployed = Q.defer()
    progress = setInterval((-> deployed.notify()), 100)

    success = (output) -> deployed.resolve(output)
    error = (output) -> deployed.reject(output)

    espruino.reset().then(-> espruino.upload(code)).finally(-> clearInterval(progress)).done(success, error)
    deployed.promise



