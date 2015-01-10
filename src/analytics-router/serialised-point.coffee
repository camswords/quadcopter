protocol = require('./protocol')

parse = (data, callback) ->
  definition = protocol.metricDefinitionByReference(data[0])

  if definition.type == 'float'
    callback
      loopReference: data[1]
      metric: definition.name
      value: data.readInt32BE(2) / 1000000

  if definition.type == 'integer'
    callback
      loopReference: data[1]
      metric: definition.name
      value: data.readUInt32BE(2)

module.exports = parse: parse
