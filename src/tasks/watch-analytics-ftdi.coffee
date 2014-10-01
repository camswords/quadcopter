
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
    props:
      c: 0
      b: 0
      e: 0
      a: 0
    pid:
      xAdjustment: 0
      yAdjustment: 0
    remoteControl:
      throttle: 0
    loopFrequency: 0

  printResults = ->
    console.log "#{analytics.time}: #{analytics.loopFrequency}Hz,
                 angle: (#{analytics.angularPosition.x.toFixed(2)},
                                   #{analytics.angularPosition.y.toFixed(2)},
                                   #{analytics.angularPosition.z.toFixed(2)}),
                 props: x- (c: #{analytics.props.c.toFixed(2)}, a: #{analytics.props.a.toFixed(2)}),
                        y- (b: #{analytics.props.b.toFixed(2)}, e: #{analytics.props.e.toFixed(2)}),
                 pid: (~x: #{analytics.pid.xAdjustment.toFixed(2)}, ~y: #{analytics.pid.yAdjustment.toFixed(2)}),
                 throttle: #{analytics.remoteControl.throttle.toFixed(2)}%"

    console.log "errors found: #{analytics.errors}" if analytics.errors > 0

  setInterval printResults, 1000


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
          analytics.props.a = value if name == 'a---.prop'
          analytics.props.b = value if name == 'b---.prop'
          analytics.props.c = value if name == 'c---.prop'
          analytics.props.e = value if name == 'e---.prop'
          analytics.pid.xAdjustment = value if name == 'xadj.pid-'
          analytics.pid.yAdjustment = value if name == 'yadj.pid-'
          analytics.remoteControl.throttle = value if name == 'thro.remo'

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
