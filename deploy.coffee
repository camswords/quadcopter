
SerialPort = require('serialport').SerialPort
Q = require('q')

serialPort = new SerialPort('/dev/tty.usbmodem1421', { baudrate: 9600 }, false)
uploaded = Q.defer()

serialPort.open ->
  setTimeout((->
    serialPort.write 'echo(0)\n reset() digitalWrite(LED1, false) echo(1)\n', (err) ->
      if err
        uploaded.reject(err)
      else
        serialPort.drain(-> uploaded.resolve() )
  ), 5000)


uploaded.promise.then((->
  serialPort.close(-> console.log('deploy successful.'))), ((err) ->
    console.log('failed to deploy due to ', err)
    serialPort.close()
  ))

waitForDeployToFinish = ->
  setTimeout((->
    if uploaded.promise.isPending()
      process.stdout.write('.')
      waitForDeployToFinish()
  ), 1000)

waitForDeployToFinish()
