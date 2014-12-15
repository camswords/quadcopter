
parse = (data, callback) ->
  name = data.toString('ascii', 0, 9)
  format = data.toString('ascii', 10, 11)

  if format == 'I'
    if data.length == 18
      callback null,
               name: name,
               timeInSeconds: data.readUInt32BE(12),
               value: data.readUInt16BE(16)

    else
      callback("data length of integer point is #{data.length}, should be 18")

  if format == 'E'
    # don't call the callback, this is not intended to be saved as a data point.
    # it is a message to be communicated to the user
    console.log('PANIC: ', data.toString('ascii', 12));

  if format == 'W'
      # don't call the callback, this is not intended to be saved as a data point.
      # it is a message to be communicated to the user
    console.log('WARN: ', data.toString('ascii', 12));


  else if format == 'F'
    if data.length == 20
      callback null,
               name: name,
               timeInSeconds: data.readUInt32BE(12),
               value: data.readInt32BE(16) / 1000000

    else
      callback("data length of float point is #{data.length}, should be 20")

  else
    callback("unable to parse point of type #{format}")


module.exports = parse: parse
