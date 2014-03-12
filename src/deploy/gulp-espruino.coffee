map = require 'map-stream'
espruino = require './espruino'
fs = require 'fs'
extend = require 'extend'

module.exports =
  deploy: (overrides) ->
    defaults =
      port: 'no-port-defined!'
      waitTimeBeforeSocketClose: 2000

    options = extend({}, defaults, overrides)

    map (file, callback) ->
      success = (output) -> callback(null, output)
      failure = (error) -> callback(error)

      espruino.deploy(file.contents.toString(), options).then(success, failure)
