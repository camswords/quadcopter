protocol = require('./protocol')

parse = (data, callback) ->
  if (data.length != 6)
    console.log('data length is not 6, hmmm')
  else
    callback null,
      loopReference: data[1]
      metric: protocol.metricNameForValue(data[0])
      value: data.readInt32BE(2) / 1000000

module.exports = parse: parse
