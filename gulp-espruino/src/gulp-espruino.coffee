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

createEspruinoCommand = (serialPort, onError) ->
  deferred = Q()

  execute: (command) ->
    deferred = Q.defer()
    serialPort.write command, (error) -> onError(error) if error
    deferred.promise

  finished: -> deferred.resolve()

createTimer = (timeoutInMillis, done) ->
  timeout = null

  ->
    clearTimeout(timeout)
    timeout = setTimeout(done, timeoutInMillis)

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
      publish = createPublisher(@, callback)
      espruinoCommand = createEspruinoCommand(serialPort, (error) -> publish.error(error))
      finishCommand = createTimer(options.idleReadTimeBeforeClose, -> espruinoCommand.finished())

      serialPort.on 'data', (data) ->
        output.append(data.toString())
        finishCommand()

      serialPort.on 'error', (error) -> publish.error(error)

      serialPort.open ->
        Q()
          .then(-> espruinoCommand.execute("reset();\n") if options.reset)
          .then(-> espruinoCommand.execute("echo(0);\n") if options.echoOff)
          .then(-> espruinoCommand.execute("{ #{chunk.contents.toString()} }\n"))
          .then(-> espruinoCommand.execute("echo(1);\n") if options.echoOff)
          .then(-> espruinoCommand.execute("save();\n") if options.save)
          .then(-> publish.content(output.all()))

    onFinish = (callback) ->
      self = this

      serialPort.close ->
        self.push(null)
        callback()

    through.obj(onSuccess, onFinish)
