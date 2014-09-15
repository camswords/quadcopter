
module.exports = ->
  SerialPort = require('serialport').SerialPort
  through = require 'through2'

  analytics =
    time: 0
    errors: 0
    angularPosition:
      x: 0
      y: 0
      z: 0
    loopFrequency: 0

  printResults = ->
    console.log "#{analytics.time}:
                 loopsPerSecond: #{analytics.loopFrequency}, 
                 angular position (#{analytics.angularPosition.x},
                                   #{analytics.angularPosition.y},
                                   #{analytics.angularPosition.z}),
                 errors: #{analytics.errors}"

  setInterval printResults, 500


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

          analytics.time = timeInSeconds
          analytics.loopFrequency = value if name == 'loop.freq'

        else
          data.errors = data.errors + 1

      else if format == 'F'
        if data.length == 20
          timeInSeconds = data.readUInt32BE(12)
          value = data.readInt32BE(16) / 1000000

          analytics.time = timeInSeconds
          analytics.angularPosition.x = value if name == 'angu.posx'
          analytics.angularPosition.y = value if name == 'angu.posy'
          analytics.angularPosition.z = value if name == 'angu.posz'

        else
          data.errors = data.errors + 1
      else
        data.errors = data.errors + 1

  serialPort = new SerialPort "/dev/cu.usbserial-A9WZZTHD", { baudrate: 115200 }, false

  serialPort.open (error) ->
    throw "failed to open serial port due to #{error}" if error
    console.log "connected..."

    buffer = new Buffer(0)

    serialPort.on 'data', (data) ->
      buffer = concatenate(buffer, data)

    parseBuffer = ->
      i = 0
      metricStartPosition = 0

      while i < buffer.length
        if buffer[i] == '|'.charCodeAt(0)
          processData buffer.slice(metricStartPosition, i)
          metricStartPosition = i + 1

        i++

      # unfinish metrics should be added back to the buffer
      buffer = buffer.slice(metricStartPosition, buffer.length)


    setInterval(parseBuffer, 1000)


  # return a stream, but never call the callback.
  # this is designed to run forever.
  through.obj(->)
