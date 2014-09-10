
module.exports = ->
  noble = require 'noble'
  through = require 'through2'

  concatenate = (bufferA, bufferB) ->
    newBuffer = new Buffer(bufferA.length + bufferB.length)
    bufferA.copy(newBuffer)
    bufferB.copy(newBuffer, bufferA.length)
    newBuffer

  process = (data) ->
      name = data.toString('ascii', 0, 9)
      format = data.toString('ascii', 10, 11)

      if format == 'I'
        if data.length == 18
          timeInSeconds = data.readUInt32BE(12)
          value = data.readUInt16BE(16)
          console.log("#{name}: #{timeInSeconds}, #{value}")
        else
          console.log "failed to parse message #{data.toString()} - expected integer messages to be length 18 but was #{data.length}"

      else if format == 'F'
        if data.length == 20
          timeInSeconds = data.readUInt32BE(12)
          value = data.readFloatBE(16)
          console.log("#{name}: #{timeInSeconds}, #{value}")
        else
          console.log "failed to parse message #{data.toString()} - expected float messages to be length 20 but was #{data.length}"
      else
        console.log "failed to parse message #{data.toString()} - unknown format #{format}"



  console.log('looking for the quadcopter...')

  noble.startScanning ["2220"]

  noble.on "discover", (peripheral) ->
    if peripheral.advertisement.localName is "RFduino"
      connect = ->
        peripheral.connect (error) ->
          console.log "failed to connect to the RFduino, error is ", error  if error

      peripheral.on "disconnect", ->
        console.log "disconnected, retrying..."
        setTimeout(connect, 100)

      peripheral.on "connect", -> peripheral.discoverServices ["2220"]

      buffer = new Buffer(0)

      peripheral.on "servicesDiscover", (services) ->
        services[0].on "characteristicsDiscover", (characteristics) ->
          characteristics[0].on "read", (data) ->
            stopBit = data.toString().indexOf('|')

            if stopBit != -1
              buffer = concatenate(buffer, data.slice(0, stopBit))
              process(buffer)
              buffer = data.slice(stopBit + 1)
            else
              buffer = concatenate(buffer, data)

          console.log "requesting data..."
          characteristics[0].notify(true)

        services[0].discoverCharacteristics ["2221"]

      connect()

  # return a stream, but never call the callback.
  # this is designed to run forever.
  through.obj(->)
