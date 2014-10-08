influx = require 'influx'
moment = require 'moment'

influxdb = influx
  host: 'localhost'
  port: 8086
  username: 'analytics'
  password: 'analytics'
  database: 'quadcopter'

startTime = null

calculateTime = (timeInSeconds) ->
  if startTime == null
    startTime = moment().subtract(timeInSeconds, 'seconds')

  startTime.clone().add(timeInSeconds, 'seconds').toDate()

pointsPerSecond = 0

save = (name, timeInSeconds, value) ->
  point =
    time: calculateTime(timeInSeconds)
    value: value

  console.log name, value, calculateTime(timeInSeconds)
  pointsPerSecond++

  influxdb.writePoint name, point, {}, (error) ->
    if error
      console.log "ah oh, error writing point to series #{name}:", error


savePointsPerSecond = ->
  point =
    time: moment().toDate()
    value: pointsPerSecond

  influxdb.writePoint 'pps-.metr', point, {}, (error) ->
    if error
      console.log "ah oh, error writing point to series pps-.metr:", error

  pointsPerSecond = 0

setInterval(savePointsPerSecond, 1000)

module.exports = save: save
