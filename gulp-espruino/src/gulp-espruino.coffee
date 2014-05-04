attachedDevices = require('serialport')
SerialPort = attachedDevices.SerialPort
spawn = require('child_process').spawn
exec = require('child_process').exec
through = require 'through2'
extend = require 'extend'
_ = require 'underscore'
tempfile = require('temp').track()
fs = require 'fs'
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

  connect: -> Q()
  close: -> Q()
  log: -> output.all()

  send: (command) ->
    commandExecuted = Q.defer()
    output.append(command) if config.capture.output

    tempfile.open 'command-to-send-to-fake-espruino', (fileError, info) ->
      if fileError
        commandExecuted.reject(fileError)
      else
        fs.write(info.fd, command)
        fs.close info.fd, (closeError) ->
          if closeError
            commandExecuted.reject(closeError)

          else
            exec "#{config.connection.fakePath} #{info.path}", (execError, stdout, stderr) ->
              if execError
                commandExecuted.reject(execError)
              else
                output.append(stdout) if config.capture.input
                output.append(stderr) if config.capture.input

                commandExecuted.resolve()

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

    if !config.connection.port &&
       !config.connection.serialNumber &&
       !config.connection.fakePath &&
       !config.connection.findFirst
      connected.reject('Espruino port, serial number, find first or fake path is not specified.')
      return connected.promise

    if config.connection.port
      connectToSerialPort(config.connection.port)

    else if config.connection.serialNumber
      attachedDevices.list (error, ports) ->
        if error
          connected.reject("Failed to find attached serial devices. Error is #{error}.")
          return connected.promise

        espruinoPort = _.find(ports, (port) -> port.serialNumber == config.connection.serialNumber)

        if !espruinoPort
          connected.reject("Espruino with serial number '#{config.connection.serialNumber}' not found.")
          return connected.promise

        connectToSerialPort(espruinoPort.comName)

    else if config.connection.findFirst
      attachedDevices.list (error, ports) ->
        if error
          connected.reject("Failed to find any attached espruino devices. Error is #{error}.")
          return connected.promise

        # totally a bad way to find it - will have to do for the moment.
        espruinoPort = _.find ports, (port) -> port.manufacturer == 'STMicroelectronics'

        if !espruinoPort
          connected.reject("Espruino with serial number '#{config.connection.serialNumber}' not found.")
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
        output: false
        input: true
      serialPortOptions:
        baudrate: 9600
      reset: true
      save: true
      connection:
        fakePath: null
        findFirst: true
        serialNumber: null
        port: null


    config = extend({}, defaults, options)

    if config.connection.fakePath
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
          .then(-> espruino.send("reset();\n") if config.reset && !config.connection.fakePath)
          .then(-> espruino.send('echo(0);\n') if !config.echoOn && !config.connection.fakePath)
          .then(-> espruino.send("{ #{file.contents.toString()} }\n"))
          .then(-> espruino.send('echo(1);\n') if !config.echoOn && !config.connection.fakePath)
          .then(-> espruino.send("save();\n") if config.save && !config.connection.fakePath)
          .then(-> publish.content(espruino.log()))
          .timeout(config.deployTimeout, "Deploy timed out after #{config.deployTimeout} milliseconds.")
          .fail((error) -> publish.error("gulp-espruino found an error, barfing. #{error}\nLog: #{espruino.log()}"))
          .finally(-> espruino.close())
          .done()
