_ = require('lodash')
moment = require('moment')

secondsReferences = {}
model = {}
onLoopCompletes = []
maximumTimeInSeconds = Infinity
startTime = null

determineSeconds = (loopReference) -> secondsReferences[loopReference]


calculateTime = (timeInSeconds) ->
  if !timeInSeconds
    return 'unknown'

  # recalculate start time on first run, or restart of device
  if timeInSeconds < maximumTimeInSeconds
    startTime = moment().subtract(timeInSeconds, 'seconds')

  maximumTimeInSeconds = timeInSeconds
  startTime.clone().add(timeInSeconds, 'seconds').toDate()


module.exports =
  onLoopComplete: (callback) -> onLoopCompletes.push(callback)

  update: (point) ->
    if (point.metric == 'secondsElapsed')
      # seconds elapsed is the first metric sent, so lets notify others of the model at this point
      _.each onLoopCompletes, (onLoopComplete) -> onLoopComplete(model)

      secondsReferences[point.loopReference] = point.value

    model[point.metric] =
      value: point.value
      loopReference: point.loopReference
      time: calculateTime(secondsReferences[point.loopReference])
      isStale: ->
        if !model[point.metric] || !model['secondsElapsed']
          return false

        model[point.metric].loopReference != model['secondsElapsed'].loopReference
      isValid: -> !model[point.metric].isStale() && model[point.metric].time != 'unknown'


