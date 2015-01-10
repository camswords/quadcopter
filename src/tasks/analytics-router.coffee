through = require 'through2'
serialIn = require '../analytics-router/serial-in'
persistence = require '../analytics-router/persistence'
serialisedPoint = require '../analytics-router/serialised-point'
representativeModel = require '../analytics-router/representative-model'
supportTeam = require '../analytics-router/support-team'
_ = require('lodash')

module.exports = ->
  connection = serialIn.connect '/dev/tty.usbserial-A90127RW', { baudrate: 115200 }
  supportTeam.initialise()

#  representativeModel.onLoopComplete (model) ->
#    _.each Object.keys(model), (metricName) ->
#      persistence.save(metricName, model[metricName].timeInSeconds, model[metricName].value)

  representativeModel.onLoopComplete (model) -> supportTeam.notify(model)

  connection.onEvent (data) ->
    serialisedPoint.parse data, (error, point) ->
      if error
        persistence.notifyOfError()
      else
        representativeModel.update(point)

  # return a stream, but never call the callback.
  # this is designed to run forever.
  through.obj(->)
