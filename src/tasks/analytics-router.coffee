SerialPort = require('serialport').SerialPort
through = require 'through2'
influx = require 'influx'
moment = require 'moment'
serialIn = require '../analytics-router/serial-in'

persistence = influx
  host: 'localhost'
  port: 8086
  username: 'analytics'
  password: 'analytics'
  database: 'quadcopter'

module.exports = ->

  startTime = null
  calculateTime = (timeInSeconds) ->
    if startTime == null
      startTime = moment().subtract(timeInSeconds, 'seconds')

    startTime.clone().add(timeInSeconds, 'seconds').toDate()

  save = (name, timeInSeconds, value) ->
    point =
      time: calculateTime(timeInSeconds)
      value: value

    console.log name, value, calculateTime(timeInSeconds)

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


  connection = serialIn.connect '/dev/cu.usbserial-A9WZZTHD', { baudrate: 115200 }
  connection.onEvent (statistic) -> processData(statistic)

  # return a stream, but never call the callback.
  # this is designed to run forever.
  through.obj(->)
