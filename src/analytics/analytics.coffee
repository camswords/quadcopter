through = require 'through2'
express = require 'express'

module.exports =
  start: ->
    app = express()
    app.use express.static(__dirname + '/grafana-1.8.1')
    app.listen 3000, -> console.log('analytics started at http://localhost:3000/')
