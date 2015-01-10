influxdb = require './influxdb'
moment = require 'moment'

pointsPerSecond = 0


saveMetaData = ->
  influxdb.save 'pps-.metr', { time: moment().toDate(), value: pointsPerSecond }
  pointsPerSecond = 0

setInterval(saveMetaData, 1000)


module.exports =
  save: (name, time, value) ->
    pointsPerSecond++
    influxdb.save(name, time: time, value: value)

