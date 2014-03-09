
SerialPort = require('serialport').SerialPort
Q = require('q')
wait = require './wait'

serialPort = new SerialPort('/dev/tty.usbmodem1421', { baudrate: 9600 }, false)
uploaded = Q.defer()
resetted = Q.defer()

serialPort.open ->
  console.log 'deploying'
  wait.until
    isSatisfied: -> !uploaded.promise.isPending()
    description: 'the deploy to upload'

  serialPort.on 'data', (data) ->
    resetted.resolve() if data.toString().match('G.Williams')

  serialPort.write 'reset()\n', (error) ->
    if error
      uploaded.reject error
    else
      serialPort.drain ->
        setTimeout((->
          uploaded.resolve()
        ), 4000);

serialPort.on 'error', (error) ->
  console.log(error)

success = ->
  console.log('\nsuccess!')
  serialPort.close()

failure = ->
  serialPort.close()

resetted.promise.then( ->
  uploaded.promise.then(success, failure)
)


