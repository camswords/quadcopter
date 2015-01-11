_ = require('lodash')

definitions =
  [{ reference: 0, name: 'secondsElapsed', type: 'integer', row: 1, column: 1 },
  { reference: 1, name: 'loopFrequency', type: 'integer', row: 1, column: 2 },
  { reference: 2, name: 'gyroscopeXPosition', type: 'float', row: 2, column: 1 },
  { reference: 3, name: 'gyroscopeYPosition', type: 'float', row: 2, column: 2 },
  { reference: 4, name: 'gyroscopeZPosition', type: 'float', row: 2, column: 3 },
  { reference: 5, name: 'gyroscopeTemperature', type: 'float', row: 2, column: 5 },
  { reference: 6, name: 'gyroscopeSampleRate', type: 'integer', row: 2, column: 4 },
  { reference: 7, name: 'accelerometerXPosition', type: 'float', row: 3, column: 1 },
  { reference: 8, name: 'accelerometerYPosition', type: 'float', row: 3, column: 2 },
  { reference: 9, name: 'accelerometerZPosition', type: 'float', row: 3, column: 3 },
  { reference: 10, name: 'accelerometerSampleRate', type: 'integer', row: 3, column: 4 },
  { reference: 11, name: 'angularXPosition', type: 'float', row: 4, column: 1 },
  { reference: 12, name: 'angularYPosition', type: 'float', row: 4, column: 2 },
  { reference: 13, name: 'angularZPosition', type: 'float', row: 4, column: 3 },
  { reference: 14, name: 'pidXAdjustment', type: 'float', row: 6, column: 1 },
  { reference: 15, name: 'pidYAdjustment', type: 'float', row: 6, column: 2 },
  { reference: 16, name: 'remotePidProportional', type: 'float', row: 5, column: 2 },
  { reference: 27, name: 'remotePidIntegral', type: 'float', row: 5, column: 3 },
  { reference: 17, name: 'remoteThrottle', type: 'float', row: 5, column: 1 },
  { reference: 18, name: 'propellorBSpeed', type: 'float', row: 7, column: 1 },
  { reference: 19, name: 'propellorESpeed', type: 'float', row: 7, column: 2 },
  { reference: 20, name: 'propellorCSpeed', type: 'float', row: 7, column: 3 },
  { reference: 21, name: 'propellorASpeed', type: 'float', row: 7, column: 4 },
  { reference: 22, name: 'metricsBufferSize', type: 'integer', row: 1, column: 3 },
  { reference: 23, name: 'debugValue1', type: 'float', row: 8, column: 1 },
  { reference: 24, name: 'debugValue2', type: 'float', row: 8, column: 2 },
  { reference: 25, name: 'debugValue3', type: 'integer', row: 8, column: 3 },
  { reference: 26, name: 'debugValue4', type: 'integer', row: 8, column: 4 }]

metricDefinitionByReference = (reference) ->
  _.find definitions, (definition) -> definition.reference == reference


module.exports =
  definitions: definitions
  numberOfDefinitions: definitions.length
  startCharacter: 'S'
  metricDefinitionByReference: metricDefinitionByReference
  payloadLength: 6
  suggestedNumberOfRows: 8