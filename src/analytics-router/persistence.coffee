influxdb = require './influxdb'
moment = require 'moment'

pointsPerSecond = 0
errorsPerSecond = 0
startTime = null

calculateTime = (timeInSeconds) ->
  if startTime == null
    startTime = moment().subtract(timeInSeconds, 'seconds')

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

    console.log timeInSeconds, name, point.value, point.time
    influxdb.save(name, point)

