map = require 'map-stream'
espruino = require './espruino'
fs = require 'fs'

module.exports =
  deploy: (port, encoding = 'utf-8') ->
    map (file, cb) ->
      code = fs.readFileSync(file.path, encoding: encoding)
      espruino.deploy(code, port).then(cb, cb)
