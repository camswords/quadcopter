influxdb = require './influxdb'
moment = require 'moment'

pointsPerSecond = 0
errorsPerSecond = 0
maximumTimeInSeconds = Infinity
startTime = null

calculateTime = (timeInSeconds) ->

  # recalculate start time on first run, or restart of device
  if timeInSeconds < maximumTimeInSeconds
    startTime = moment().subtract(timeInSeconds, 'seconds')

  maximumTimeInSeconds = timeInSeconds
  startTime.clone().add(timeInSeconds, 'seconds').toDate()

saveMetaData = ->
  now = moment().toDate()

  influxdb.save 'pps-.metr', { time: now, value: pointsPerSecond }
  influxdb.save 'seri.err-', { time: now, value: errorsPerSecond }

  pointsPerSecond = 0
  errorsPerSecond = 0


setInterval(saveMetaData, 1000)


module.exports =
  notifyOfError: ->
    errorsPerSecond++

  save: (name, timeInSeconds, value) ->
    pointsPerSecond++
    point = time: calculateTime(timeInSeconds), value: value

    influxdb.save(name, point)

