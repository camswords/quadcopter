map = require 'map-stream'
espruino = require './espruino'
fs = require 'fs'
extend = require 'extend'

module.exports =
  deploy: (overrides) ->
    defaults =
      port: 'no-port-defined!'
      waitTimeBeforeSocketClose: 1000

    options = extend({}, defaults, overrides)

    map (file, cb) -> espruino.deploy(file.contents.toString(), options).then(cb, cb)
