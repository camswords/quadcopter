
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


module.exports = parse: -> parse
