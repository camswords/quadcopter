SerialPort = require('serialport').SerialPort
fs = require 'fs'
through = require 'through2'
extend = require 'extend'
Q = require 'q'

output = (->
  consumed = ''

  append: (content) -> consumed += content
  all: -> consumed
)()

module.exports =
  deploy: (port, overrides = {}) ->

    defaults =
      echoOff: true
      idleReadTimeBeforeClose: 1000
      reset: true
      save: true

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

      executor = (->
        deferred = Q()

        execute: (command) ->
          deferred = Q.defer()
          serialPort.write command, (error) -> publish.error(error) if error
          deferred.promise

        finished: -> deferred.resolve()
      )()

      consume = (->
        timeout = null

        (content) ->
          output.append(content)
          clearTimeout(timeout)
          timeout = setTimeout((-> executor.finished()), options.idleReadTimeBeforeClose)
      )()

      serialPort.on 'data', (data) -> consume(data.toString())
      serialPort.on 'error', (error) -> publish.error(null, error)

      serialPort.open ->
        Q()
          .then(-> executor.execute("reset();\n") if options.reset)
          .then(-> executor.execute("echo(0);\n") if options.echoOff)
          .then(->
            code = chunk.contents?.toString() || chunk
            executor.execute("{ #{code} }\n"))
          .then(-> executor.execute("echo(1);\n") if options.echoOff)
          .then(-> executor.execute("save();\n") if options.save)
          .then(-> publish.content(output.all() unless publish.published()))

    onFinish = (callback) ->
      self = this

      serialPort.close ->
        self.push(null)
        callback()

    through.obj(onSuccess, onFinish)
