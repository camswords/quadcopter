influx = require 'influx'

influxdb = influx
  host: 'localhost'
  port: 8086
  username: 'analytics'
  password: 'analytics'
  database: 'quadcopter'


module.exports =
  save: (name, point) ->
    influxdb.writePoint name, point, {}, (error) ->
      if error
        console.log "ah oh, error writing point to series #{name}:", error
