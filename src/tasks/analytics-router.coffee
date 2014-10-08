through = require 'through2'
serialIn = require '../analytics-router/serial-in'
persistence = require '../analytics-router/persistence'

module.exports = ->
  processEvent = (data) ->
      name = data.toString('ascii', 0, 9)
      format = data.toString('ascii', 10, 11)

      if format == 'I'
        if data.length == 18
          timeInSeconds = data.readUInt32BE(12)
          value = data.readUInt16BE(16)
          persistence.save(name, timeInSeconds, value)

        else
          persistence.save('seri.err-', value: 1)

      else if format == 'F'
        if data.length == 20
          timeInSeconds = data.readUInt32BE(12)
          value = data.readInt32BE(16) / 1000000
          persistence.save(name, timeInSeconds, value)

        else
          persistence.save('seri.err-', value: 1)
      else
        persistence.save('seri.err-', value: 1)


  connection = serialIn.connect '/dev/cu.usbserial-A9WZZTHD', { baudrate: 115200 }
  connection.onEvent (statistic) -> processEvent(statistic)

  # return a stream, but never call the callback.
  # this is designed to run forever.
  through.obj(->)
