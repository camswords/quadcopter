attachedDevices = require('serialport')
SerialPort = attachedDevices.SerialPort
through = require 'through2'
extend = require 'extend'
_ = require 'underscore'
Q = require 'q'
PluginError = require('gulp-util').PluginError;

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

createEspruino = (config) ->
  output = createOutput()
  commandExecuted = Q.defer()
  connected = Q.defer()
  finishCommand = createTimer(config.idleReadTimeBeforeClose, -> commandExecuted.resolve())

  connect: ->
    connectToSerialPort = (port) ->
      serialPort = new SerialPort(port, baudrate: 9600)

      serialPort.on 'data', (data) ->
        output.append(data.toString())
        finishCommand()

      connected.resolve(serialPort)

    if !config.port && !config.serialNumber
      throw new PluginError('gulp-espruino', 'Espruino port or serial number is not specified. Barfing.');

    if config.port
      connectToSerialPort(config.port)

    if !config.port && config.serialNumber
      attachedDevices.list (error, ports) ->
        if error
          throw new PluginError('gulp-espruino', "Failed to find attached serial devices. Error is #{error}. Barfing.")

        espruinoPort = _.find(ports, (port) -> port.serialNumber == config.serialNumber)

        if !espruinoPort
          throw new PluginError('gulp-espruino', "Espruino with serial number '#{config.serialNumber}' not found. Barfing. We did find these ports: #{JSON.stringify(ports)}.")

        connectToSerialPort(espruinoPort.comName)

    connected.promise

  close: (callback) -> connected.promise.then((serialPort) -> serialPort.close(callback))
  log: -> output.all()
  send: (command, onError) ->
    connected.promise.then (serialPort) ->
      serialPort.on('error', onError)
      commandExecuted = Q.defer()
      serialPort.write command, (error) -> onError(error) if error
      commandExecuted.promise

module.exports =
  deploy: (options = {}) ->
    defaults =
      echoOff: true
      idleReadTimeBeforeClose: 1000
      reset: true
      save: true

    config = extend({}, defaults, options)
    espruino = createEspruino(config)
    connected = espruino.connect()

    onTransform = (chunk, encoding, callback) ->
      publish = createPublisher(@, callback)
      onError = (error) -> publish.error(error)

      connected.then(-> espruino.send("reset();\n", onError) if config.reset)
         .then(-> espruino.send("echo(0);\n", onError) if config.echoOff)
         .then(-> espruino.send("{ #{chunk.contents.toString()} }\n", onError))
         .then(-> espruino.send("echo(1);\n", onError) if config.echoOff)
         .then(-> espruino.send("save();\n", onError) if config.save)
         .then(-> publish.content(espruino.log()))

    onFlush = (callback) ->
      publish = createPublisher(@, callback)
      espruino.close -> publish.content(null)

    through.obj(onTransform, onFlush)

# Todo.
# blow up if not stream
# move espruino close to finally
# add in hook to finish stream slurp whenever you want
# reject promise on error
# add timeout to promise chain
