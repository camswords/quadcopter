noble = require 'noble'
through = require 'through2'

recordMessage = (->
  line = ''

  (linePart) ->
    unless linePart.indexOf("|") is -1
      newLineIndex = linePart.indexOf("|") + 1
      console.log line + linePart.slice(0, newLineIndex)
      line = ''
      recordMessage linePart.slice(newLineIndex)
    else
      line += linePart
    return
)()

module.exports = ->
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

      peripheral.on "servicesDiscover", (services) ->
        services[0].on "characteristicsDiscover", (characteristics) ->
          characteristics[0].on "read", (data) -> recordMessage(data.toString())

          console.log "requesting data..."
          characteristics[0].notify(true)

        services[0].discoverCharacteristics ["2221"]

      connect()

  # return a stream, but never call the callback.
  # this is designed to run forever.
  through.obj(->)
