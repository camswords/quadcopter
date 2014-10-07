SerialPort = require('serialport').SerialPort
through = require 'through2'
influx = require 'influx'
moment = require 'moment'

persistence = influx
  host: 'localhost'
  port: 8086
  username: 'analytics'
  password: 'analytics'
  database: 'quadcopter'

module.exports = ->
  concatenate = (bufferA, bufferB) ->
    newBuffer = new Buffer(bufferA.length + bufferB.length)
    bufferA.copy(newBuffer)
    bufferB.copy(newBuffer, bufferA.length)
    newBuffer

  startTime = null
  calculateTime = (timeInSeconds) ->
    if startTime == null
      startTime = moment().subtract(timeInSeconds, 'seconds')

    startTime.add(timeInSeconds, 'seconds').toDate()

  save = (name, timeInSeconds, value) ->
    point =
      time: calculateTime(timeInSeconds)
      value: value

    persistence.writePoint name, point, {}, (error) ->
      if error
        console.log "ah oh, error writing point to series #{name}:", error

  processData = (data) ->
      name = data.toString('ascii', 0, 9)
      format = data.toString('ascii', 10, 11)

      if format == 'I'
        if data.length == 18
          timeInSeconds = data.readUInt32BE(12)
          value = data.readUInt16BE(16)
          save(name, timeInSeconds, value)

        else
          save('seri.err-', value: 1)

      else if format == 'F'
        if data.length == 20
          timeInSeconds = data.readUInt32BE(12)
          value = data.readInt32BE(16) / 1000000
          save(name, timeInSeconds, value)

        else
          save('seri.err-', value: 1)
      else
        save('seri.err-', value: 1)

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
