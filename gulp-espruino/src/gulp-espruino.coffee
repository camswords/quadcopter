SerialPort = require('serialport').SerialPort
through = require 'through2'
extend = require 'extend'
Q = require 'q'

createOutput = ->
  consumed = ''

  append: (content) -> consumed += content
  all: -> consumed

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

createEspruino = (port, options) ->
  serialPort = new SerialPort(port, { baudrate: 9600 })
  output = createOutput()
  commandExecuted = Q.defer()

  finishCommand = createTimer(options.idleReadTimeBeforeClose, -> commandExecuted.resolve())

  serialPort.on 'data', (data) ->
    output.append(data.toString())
    finishCommand()

  log: -> output.all()
  close: (callback) -> serialPort.close(callback)
  send: (command, onError) ->
    serialPort.on('error', onError)
    commandExecuted = Q.defer()
    serialPort.write command, (error) -> onError(error) if error
    commandExecuted.promise

module.exports =
  deploy: (port, overrides = {}) ->

    defaults =
      echoOff: true
      idleReadTimeBeforeClose: 1000
      reset: true
      save: true

    options = extend({}, defaults, overrides)
    espruino = createEspruino(port, options)

    onTransform = (chunk, encoding, callback) ->
      publish = createPublisher(@, callback)
      onError = (error) -> publish.error(error)

      Q().then(-> espruino.send("reset();\n", onError) if options.reset)
         .then(-> espruino.send("echo(0);\n", onError) if options.echoOff)
         .then(-> espruino.send("{ #{chunk.contents.toString()} }\n", onError))
         .then(-> espruino.send("echo(1);\n", onError) if options.echoOff)
         .then(-> espruino.send("save();\n", onError) if options.save)
         .then(-> publish.content(espruino.log()))

    onFlush = (callback) ->
      publish = createPublisher(@, callback)
      espruino.close -> publish.content(null)

    through.obj(onTransform, onFlush)
