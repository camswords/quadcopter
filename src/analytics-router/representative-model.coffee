protocol = require('./protocol')
_ = require('lodash')
moment = require('moment')

secondsReferences = []
model = {}
onLoopComplete = ->
maximumTimeInSeconds = Infinity
startTime = null

determineSeconds = (loopReference) ->
  reference = _.find secondsReferences, (reference) -> reference.loopReference == loopReference
  reference.seconds if (reference)


calculateTime = (timeInSeconds) ->
  if !timeInSeconds
    return 'unknown'

  # recalculate start time on first run, or restart of device
  if timeInSeconds < maximumTimeInSeconds
    startTime = moment().subtract(timeInSeconds, 'seconds')

  maximumTimeInSeconds = timeInSeconds
  startTime.clone().add(timeInSeconds, 'seconds').toDate()


module.exports =
  onLoopComplete: (callback) -> onLoopComplete = callback

  update: (point) ->
    if (point.metric == 'secondsElapsed')
      secondsReferences.push
        loopReference: point.loopReference
        seconds: point.value

      # seconds elapsed is the first metric sent, so lets notify others of the model at this point
      onLoopComplete(model)

    model[point.metric] =
      value: point.value
      loopReference: point.loopReference
      timeInSeconds: calculateTime(determineSeconds(point.loopReference))


