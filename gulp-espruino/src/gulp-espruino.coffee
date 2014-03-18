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
      serialPort = new SerialPort(port, { baudrate: 9600 }, false)

      serialPort.on 'data', (data) ->
        output.append(data.toString())
        finishCommand()

      serialPort.on 'error', (error) -> commandExecuted.reject(error)

      serialPort.open -> connected.resolve(serialPort)

    if !config.port && !config.serialNumber
      connected.reject('Espruino port or serial number is not specified. Barfing.')
      return connected.promise

    if config.port
      connectToSerialPort(config.port)

    if !config.port && config.serialNumber
      attachedDevices.list (error, ports) ->
        if error
          connected.reject("Failed to find attached serial devices. Error is #{error}. Barfing.")
          return connected.promise

        espruinoPort = _.find(ports, (port) -> port.serialNumber == config.serialNumber)

        if !espruinoPort
          connected.reject("Espruino with serial number '#{config.serialNumber}' not found. Barfing. We did find these ports: #{JSON.stringify(ports)}.")
          return connected.promise

        connectToSerialPort(espruinoPort.comName)

    connected.promise

  close: ->
    closed = Q.defer()
    connected.promise.then((serialPort) -> serialPort.close(-> closed.resolve()))
    closed.promise
  log: -> output.all()
  send: (command) ->
    connected.promise.then (serialPort) ->
      commandExecuted = Q.defer()
      serialPort.write command, (error) -> commandExecuted.reject(error) if error
      commandExecuted.promise

module.exports =
  deploy: (options = {}) ->
    defaults =
      echoOff: true
      deployTimeout: 15000
      idleReadTimeBeforeClose: 1000
      reset: true
      save: true

    config = extend({}, defaults, options)
    espruino = createEspruino(config)

    through.obj (file, encoding, callback) ->
      publish = createPublisher(@, callback)

      if file.isNull()
        publish.content(file)

      if file.isBuffer()
        espruino.connect()
          .then(-> espruino.send("reset();\n") if config.reset)
          .then(-> espruino.send("echo(0);\n") if config.echoOff)
          .then(-> espruino.send("{ #{file.contents.toString()} }\n"))
          .then(-> espruino.send("echo(1);\n") if config.echoOff)
          .then(-> espruino.send("save();\n") if config.save)
          .then(-> publish.content(espruino.log()))
          .timeout(config.deployTimeout, "Deploy timed out after #{config.deployTimeout} milliseconds. Barfing.")
          .fail((error) -> publish.error(error))
          .finally(-> espruino.close())
          .done()

# Todo.
# blow up if not stream
# add in hook to finish stream slurp whenever you want
# add timeout to promise chain
