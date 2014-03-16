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

createTimer = (timeoutInMillis, done) ->
  timeout = null

  ->
    clearTimeout(timeout)
    timeout = setTimeout(done, timeoutInMillis)

createEspruino = (port) ->
  serialPort = new SerialPort(port, { baudrate: 9600 })
  commandExecuted = Q.defer()

  serialPort: serialPort

  send: (command, onError) ->
    commandExecuted = Q.defer()
    serialPort.write command, (error) -> onError(error) if error
    commandExecuted.promise

  sendFinished: -> commandExecuted.resolve()

  close: (callback) -> serialPort.close(callback)

module.exports =
  deploy: (port, overrides = {}) ->

    defaults =
      echoOff: true
      idleReadTimeBeforeClose: 1000
      reset: true
      save: true

    espruino = createEspruino(port)

    options = extend({}, defaults, overrides)
    serialPort = espruino.serialPort

    onTransform = (chunk, encoding, callback) ->
      publish = createPublisher(@, callback)
      onError = (error) -> publish.error(error)
      finishCommand = createTimer(options.idleReadTimeBeforeClose, -> espruino.sendFinished())

      serialPort.on 'data', (data) ->
        output.append(data.toString())
        finishCommand()

      serialPort.on('error', onError)

      Q()
        .then(-> espruino.send("reset();\n", onError) if options.reset)
        .then(-> espruino.send("echo(0);\n", onError) if options.echoOff)
        .then(-> espruino.send("{ #{chunk.contents.toString()} }\n", onError))
        .then(-> espruino.send("echo(1);\n", onError) if options.echoOff)
        .then(-> espruino.send("save();\n", onError) if options.save)
        .then(-> publish.content(output.all()))

    onFlush = (callback) ->
      self = this

      espruino.close ->
        self.push(null)
        callback()

    through.obj(onTransform, onFlush)
