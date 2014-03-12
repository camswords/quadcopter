Q = require 'q'
SerialPort = require('serialport').SerialPort

sendToSerial = (message, port) ->
  written = Q.defer()
  read = ''

  finalise = ->
    written.resolve(read)
    serialPort.close()

  serialPort = new SerialPort(port, { baudrate: 9600 }, false)

  serialPort.on 'error', (error) -> written.reject(error)
  serialPort.on 'data', (data) -> read += data.toString()

  serialPort.open ->
    serialPort.write message, (error) ->
      if error
        written.reject(error)
      else
        serialPort.drain -> setTimeout(finalise, 1000)

  written.promise

espruino =
  reset: (port) -> sendToSerial('reset();\n', port)
  save: (port) -> sendToSerial('save();\n', port)
  upload: (code, port) -> sendToSerial("{ #{code} }\n", port)

module.exports =
  deploy: (code, port) ->
    deployed = Q.defer()
    progress = setInterval((-> deployed.notify()), 100)

    success = (output) -> deployed.resolve(output)
    error = (output) -> deployed.reject(output)

    espruino.reset(port)
        .then(-> espruino.upload(code, port))
        .then(-> espruino.save(port))
        .finally(-> clearInterval(progress))
        .done(success, error)

    deployed.promise



