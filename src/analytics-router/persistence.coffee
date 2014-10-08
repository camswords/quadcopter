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
errorsPerSecond = 0

save = (name, timeInSeconds, value) ->
  point =
    time: calculateTime(timeInSeconds)
    value: value

  console.log timeInSeconds, name, value, calculateTime(timeInSeconds)
  pointsPerSecond++

  influxdb.writePoint name, point, {}, (error) ->
    if error
      console.log "ah oh, error writing point to series #{name}:", error

notifyOfError = -> errorsPerSecond++

saveMetaData = ->
  now = moment().toDate()

  pointsPerSecondPoint = time: now, value: pointsPerSecond

  influxdb.writePoint 'pps-.metr', pointsPerSecondPoint, {}, (error) ->
    if error
      console.log "ah oh, error writing point to series pps-.metr:", error

  errorsPerSecondPoint = time: now, value: errorsPerSecond

  influxdb.writePoint 'seri.err-', errorsPerSecondPoint, {}, (error) ->
    if error
      console.log "ah oh, error writing point to series seri.err-:", error

  pointsPerSecond = 0
  errorsPerSecond = 0

setInterval(saveMetaData, 1000)

module.exports =
  save: save
  notifyOfError: notifyOfError
