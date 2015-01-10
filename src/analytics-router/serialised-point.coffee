protocol = require('./protocol')

parse = (data, callback) ->
  if (data.length != 6)
    console.log('data length is not 6, hmmm')
  else
    console.log(data[1], 'type', protocol.metricNameForValue(data[0]), data.readInt32BE(2) / 1000000);
    console.log()
module.exports = parse: parse
