SerialPort = require('serialport').SerialPort
fs = require 'fs'
through = require 'through2'
extend = require 'extend'

module.exports =
  deploy: (port, overrides = {}) ->

    defaults = idleReadTimeBeforeClose: 1000
    options = extend({}, defaults, overrides)
    serialPort = new SerialPort(port, { baudrate: 9600 })

    onSuccess = (chunk, encoding, callback) ->
      self = this

      publish = (->
        published = false

        content: (content) ->
          published = true
          self.push(content)
          callback()

        error: (error) ->
          published = true
          self.push(null)
          callback(error)

        published: -> published
      )()

      consume = (->
        consumed = ''
        timeout = null

        (content) ->
          consumed += content
          clearTimeout(timeout)
          timeout = setTimeout((-> publish.content(consumed) unless publish.published()), options.idleReadTimeBeforeClose)
      )()

      serialPort.on 'data', (data) -> consume(data.toString())
      serialPort.on 'error', (error) -> publish.error(null, error)

      serialPort.open ->
        serialPort.write "reset();\n { #{chunk.contents.toString()} }\n save();\n", (error) ->
          publish.error(error) if error

    onFinish = (callback) ->
      self = this

      serialPort.close ->
        self.push(null)
        callback()

    through.obj(onSuccess, onFinish)
