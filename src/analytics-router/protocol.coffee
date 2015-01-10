_ = require('lodash')

metrics =
  secondsElapsed: 0
  loopFrequency: 1
  gyroscopeXPosition: 2
  gyroscopeYPosition: 3
  gyroscopeZPosition: 4
  gyroscopeTemperature: 5
  gyroscopeSampleRate: 6
  accelerometerXPosition: 7
  accelerometerYPosition: 8
  accelerometerZPosition: 9
  accelerometerSampleRate: 10
  angularXPosition: 11
  angularYPosition: 12
  angularZPosition: 13
  pidXAdjustment: 14
  pidYAdjustment: 15
  pidProportional: 16
  remoteThrottle: 17
  propellorBSpeed: 18
  propellorESpeed: 19
  propellorCSpeed: 20
  propellorASpeed: 21
  metricsBufferSize: 22

metricNameForValue = (value) ->
  _.find Object.keys(metrics), (metricName) -> metrics[metricName] == value


module.exports =
  metrics: metrics
  startCharacter: 'S'
  metricNameForValue: metricNameForValue