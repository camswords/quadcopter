_ = require('lodash')

definitions =
  [{ reference: 0, name: 'secondsElapsed', type: 'integer' },
  { reference: 1, name: 'loopFrequency', type: 'integer' },
  { reference: 2, name: 'gyroscopeXPosition', type: 'float' },
  { reference: 3, name: 'gyroscopeYPosition', type: 'float' },
  { reference: 4, name: 'gyroscopeZPosition', type: 'float' },
  { reference: 5, name: 'gyroscopeTemperature', type: 'float' },
  { reference: 6, name: 'gyroscopeSampleRate', type: 'integer' },
  { reference: 7, name: 'accelerometerXPosition', type: 'float' },
  { reference: 8, name: 'accelerometerYPosition', type: 'float' },
  { reference: 9, name: 'accelerometerZPosition', type: 'float' },
  { reference: 10, name: 'accelerometerSampleRate', type: 'integer' },
  { reference: 11, name: 'angularXPosition', type: 'float' },
  { reference: 12, name: 'angularYPosition', type: 'float' },
  { reference: 13, name: 'angularZPosition', type: 'float' },
  { reference: 14, name: 'pidXAdjustment', type: 'float' },
  { reference: 15, name: 'pidYAdjustment', type: 'float' },
  { reference: 16, name: 'pidProportional', type: 'float' },
  { reference: 17, name: 'remoteThrottle', type: 'float' },
  { reference: 18, name: 'propellorBSpeed', type: 'float' },
  { reference: 19, name: 'propellorESpeed', type: 'float' },
  { reference: 20, name: 'propellorCSpeed', type: 'float' },
  { reference: 21, name: 'propellorASpeed', type: 'float' },
  { reference: 22, name: 'metricsBufferSize', type: 'integer' },
  { reference: 23, name: 'debugValue1', type: 'float' },
  { reference: 24, name: 'debugValue2', type: 'float' },
  { reference: 25, name: 'debugValue3', type: 'integer' },
  { reference: 26, name: 'debugValue4', type: 'integer' }]

metricDefinitionByReference = (reference) ->
  _.find definitions, (definition) -> definition.reference == reference


module.exports =
  definitions: definitions
  numberOfDefinitions: definitions.length
  startCharacter: 'S'
  metricDefinitionByReference: metricDefinitionByReference
  payloadLength: 6