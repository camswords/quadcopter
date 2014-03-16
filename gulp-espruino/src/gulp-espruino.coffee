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

createPublisher = (readableStream, readableStreamDone) ->
  published = false

  content: (content) ->
    if !published
      published = true
      readableStream.push(content)
      readableStreamDone()

  error: (error) ->
    if !published
      published = true
      readableStream.push(null)
      readableStreamDone(error)

createExecutor = (serialPort, publish) ->
  deferred = Q()

  execute: (command) ->
    deferred = Q.defer()
    serialPort.write command, (error) -> publish.error(error) if error
    deferred.promise

  finished: -> deferred.resolve()


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

      publish = createPublisher(self, callback)
      executor = createExecutor(serialPort, publish)

      consume = (->
        timeout = null

        ->
          clearTimeout(timeout)
          timeout = setTimeout((-> executor.finished()), options.idleReadTimeBeforeClose)
      )()

      serialPort.on 'data', (data) ->
        output.append(data.toString())
        consume(data.toString())

      serialPort.on 'error', (error) -> publish.error(error)

      serialPort.open ->
        Q()
          .then(-> executor.execute("reset();\n") if options.reset)
          .then(-> executor.execute("echo(0);\n") if options.echoOff)
          .then(-> executor.execute("{ #{chunk.contents.toString()} }\n"))
          .then(-> executor.execute("echo(1);\n") if options.echoOff)
          .then(-> executor.execute("save();\n") if options.save)
          .then(-> publish.content(output.all()))

    onFinish = (callback) ->
      self = this

      serialPort.close ->
        self.push(null)
        callback()

    through.obj(onSuccess, onFinish)
