attachedDevices = require('serialport')
SerialPort = attachedDevices.SerialPort
spawn = require('child_process').spawn
through = require 'through2'
extend = require 'extend'
_ = require 'underscore'
Q = require 'q'
PluginError = require('gulp-util').PluginError;

createOutput = ->
  consumed = ''

  append: (content) -> consumed += content
  all: -> consumed

createPublisher = (inputFile, outputStream, outputStreamDone) ->
  published = false

  content: (contents) ->
    if !published
      published = true

      if contents || contents == ''
        inputFile.contents = new Buffer(contents)
      else
        inputFile.contents = contents

      outputStream.push(inputFile)
      outputStreamDone()

  error: (error) ->
    if !published
      published = true
      outputStream.push(null)
      outputStreamDone(error)

createTimer = (timeoutInMillis, done) ->
  timeout = null

  ->
    clearTimeout(timeout)
    timeout = setTimeout(done, timeoutInMillis)

createFakeEspruino = (config) ->
  output = createOutput()
  commandExecuted = Q.defer()
  connected = Q.defer()
  finishCommand = createTimer(config.idleReadTimeBeforeClose, -> commandExecuted.resolve())

  connect: ->
    espruinoProcess = spawn(config.fakePath)

    espruinoProcess.stdout.on 'data', (data) ->
      output.append(data.toString()) if config.capture.input
      finishCommand()

    espruinoProcess.stdout.on 'error', (error) ->
      commandExecuted.reject(error)

    espruinoProcess.stdin.on 'error', (error) ->
      commandExecuted.reject(error)

    connected.resolve(espruinoProcess)
    connected.promise

  close: -> connected.promise.then (espruinoProcess) ->
    espruinoProcess.stdin.write('\x03')

  log: -> output.all()

  send: (command) ->
    connected.promise.then (espruinoProcess) ->
      commandExecuted = Q.defer()
      output.append(command) if config.capture.output
      espruinoProcess.stdin.write(command)
      commandExecuted.promise

createEspruino = (config) ->
  output = createOutput()
  commandExecuted = Q.defer()
  connected = Q.defer()
  finishCommand = createTimer(config.idleReadTimeBeforeClose, -> commandExecuted.resolve())

  connect: ->
    connectToSerialPort = (port) ->
      serialPort = new SerialPort(port, config.serialPortOptions, false)

      serialPort.on 'data', (data) ->
        output.append(data.toString()) if config.capture.input
        finishCommand()

      serialPort.on 'error', (error) -> commandExecuted.reject(error)

      serialPort.open -> connected.resolve(serialPort)

    if !config.port && !config.serialNumber
      connected.reject('Espruino port or serial number is not specified.')
      return connected.promise

    if config.port
      connectToSerialPort(config.port)

    if !config.port && config.serialNumber
      attachedDevices.list (error, ports) ->
        if error
          connected.reject("Failed to find attached serial devices. Error is #{error}.")
          return connected.promise

        espruinoPort = _.find(ports, (port) -> port.serialNumber == config.serialNumber)

        if !espruinoPort
          connected.reject("Espruino with serial number '#{config.serialNumber}' not found.")
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
      output.append(command) if config.capture.output
      serialPort.write command, (error) -> commandExecuted.reject(error) if error
      commandExecuted.promise

module.exports =
  deploy: (options = {}) ->
    defaults =
      deployTimeout: 15000
      echoOn: true
      idleReadTimeBeforeClose: 1000
      capture:
        output: true
        input: true
      serialPortOptions:
        baudrate: 9600
      reset: true
      save: true
      fakePath: null

    config = extend({}, defaults, options)

    if config.fakePath
      espruino = createFakeEspruino(config)
    else
      espruino = createEspruino(config)

    through.obj (file, encoding, callback) ->
      publish = createPublisher(file, @, callback)

      if file.isNull()
        publish.content(null)

      if file.isStream()
        publish.error('gulp-espruino does not support streaming. Barfing.')

      if file.isBuffer()
        espruino.connect()
          .then(-> espruino.send("reset();\n") if config.reset)
          .then(-> espruino.send('echo(0);\n') if !config.echoOn)
          .then(-> espruino.send("{ #{file.contents.toString()} }\n"))
          .then(-> espruino.send('echo(1);\n') if !config.echoOn)
          .then(-> espruino.send("save();\n") if config.save)
          .then(-> publish.content(espruino.log()))
          .timeout(config.deployTimeout, "Deploy timed out after #{config.deployTimeout} milliseconds.")
          .fail((error) -> publish.error("gulp-espruino found an error, barfing. #{error}\nLog: #{espruino.log()}"))
          .finally(-> espruino.close())
          .done()
