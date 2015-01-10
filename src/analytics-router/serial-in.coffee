SerialPort = require('serialport').SerialPort
protocol = require('./protocol')

concatenate = (bufferA, bufferB) ->
  newBuffer = new Buffer(bufferA.length + bufferB.length)
  bufferA.copy(newBuffer)
  bufferB.copy(newBuffer, bufferA.length)
  newBuffer


Connection =
  create: ->
    buffer = new Buffer(0)

    appendToBuffer: (data) ->
      previousBuffer = buffer
      buffer = new Buffer(previousBuffer.length + data.length)
      previousBuffer.copy(buffer)
      data.copy(buffer, previousBuffer.length)

    onEvent: (callback) ->
      parseBuffer = ->
        i = 0
        metricStartPosition = 0

        while i < buffer.length
          if buffer[i] == protocol.startCharacter.charCodeAt(0)
            callback buffer.slice(metricStartPosition, i)
            metricStartPosition = i + 1

          i++

        # unfinished metrics should be added back to the buffer
        buffer = buffer.slice(metricStartPosition, buffer.length)

      setInterval(parseBuffer, 200)

connect = (port, options) ->
  serialPort = new SerialPort port, options, false

  connection = Connection.create()

  serialPort.open (error) ->
    throw "failed to open serial port #{port} due to #{error}" if error
    console.log "connected..."

    serialPort.on 'data', (data) -> connection.appendToBuffer(data)

  connection

module.exports = connect: connect
