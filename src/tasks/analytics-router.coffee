through = require 'through2'
serialIn = require '../analytics-router/serial-in'
persistence = require '../analytics-router/persistence'
serialisedPoint = require '../analytics-router/serialised-point'

module.exports = ->
  connection = serialIn.connect '/dev/cu.usbserial-A9WZZTHD', { baudrate: 115200 }

  connection.onEvent (data) ->
    serialisedPoint.parse data, (error, point) ->
      if error
        persistence.notifyOfError()
      else
        persistence.save(point.name, point.timeInSeconds, point.value)

  # return a stream, but never call the callback.
  # this is designed to run forever.
  through.obj(->)
