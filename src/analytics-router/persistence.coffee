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

save = (name, timeInSeconds, value) ->
  point =
    time: calculateTime(timeInSeconds)
    value: value

  console.log name, value, calculateTime(timeInSeconds)

  influxdb.writePoint name, point, {}, (error) ->
    if error
      console.log "ah oh, error writing point to series #{name}:", error

module.exports = save: save
