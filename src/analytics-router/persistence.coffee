influxdb = require './influxdb'
moment = require 'moment'

pointsPerSecond = 0

module.exports =
  measureMetricThroughPut: ->
    saveMetaData = ->
      influxdb.save 'pps-.metr', { time: moment().toDate(), value: pointsPerSecond }
      pointsPerSecond = 0
    
    setInterval(saveMetaData, 1000)
    
  save: (name, time, value) ->
    pointsPerSecond++
    influxdb.save(name, time: time, value: value)

