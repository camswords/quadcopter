
SerialPort = require('serialport').SerialPort
Q = require('q')
wait = require './wait'

serialPort = new SerialPort('/dev/tty.usbmodem1421', { baudrate: 9600 }, false)
uploaded = Q.defer()
resetted = Q.defer()

serialPort.open ->
  wait.until
    isSatisfied: -> !uploaded.promise.isPending()
    description: 'the deploy to upload'

  serialPort.on 'data', (data) ->
    console.log(data.toString())

    if data.toString().match('G.Williams')
      resetted.resolve()

  serialPort.write 'reset()\n', (error) ->
    if error
      console.log('error', error)
      uploaded.reject error
    else
      serialPort.drain ->
        setTimeout((->
          uploaded.resolve()
        ), 10000);

serialPort.on 'error', (error) ->
  console.log(error)

success = ->
  console.log('deploy successful')
  serialPort.close()

failure = ->
  serialPort.close()

resetted.promise.then(uploaded.promise).then(success, failure)


