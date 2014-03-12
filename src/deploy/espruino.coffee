Q = require 'q'
SerialPort = require('serialport').SerialPort

sendToSerial = (message, options) ->
  written = Q.defer()
  read = ''

  finalise = ->
    written.resolve(read)
    serialPort.close()

  serialPort = new SerialPort(options.port, { baudrate: 9600 }, false)

  serialPort.on 'error', (error) -> written.reject(error)
  serialPort.on 'data', (data) -> read += data.toString()

  serialPort.open ->
    serialPort.write message, (error) ->
      if error
        written.reject(error)
      else
        serialPort.drain -> setTimeout(finalise, options.waitTimeBeforeSocketClose)

  written.promise

espruino =
  upload: (code, options) -> sendToSerial("reset();\n { #{code} }\n save();\n", options)

module.exports =
  deploy: (code, options) ->
    deployed = Q.defer()

    success = (output) -> deployed.resolve(output)
    error = (output) -> deployed.reject(output)

    espruino.upload(code, options).done(success, error)

    deployed.promise



