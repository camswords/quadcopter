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

createPublisher = (inputFile, outputStream, outputStreamDone) ->
  published = false

  content: (contents) ->
    if !published
      published = true

      if contents
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

createEspruino = (config) ->
  output = createOutput()
  commandExecuted = Q.defer()
  connected = Q.defer()
  finishCommand = createTimer(config.idleReadTimeBeforeClose, -> commandExecuted.resolve())

  connect: ->
    connectToSerialPort = (port) ->
      serialPort = new SerialPort(port, config.serialPortOptions, false)

      serialPort.on 'data', (data) ->
        output.append(data.toString())
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
          connected.reject("Espruino with serial number '#{config.serialNumber}' not found. We did find these ports: #{JSON.stringify(ports)}.")
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
      output.append(command)
      serialPort.write command, (error) -> commandExecuted.reject(error) if error
      commandExecuted.promise

module.exports =
  deploy: (options = {}) ->
    defaults =
      deployTimeout: 15000
      idleReadTimeBeforeClose: 1000
      serialPortOptions:
        baudrate: 9600
      reset: true
      save: true

    config = extend({}, defaults, options)
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
          .then(-> espruino.send("{ #{file.contents.toString()} }\n"))
          .then(-> espruino.send("save();\n") if config.save)
          .then(-> publish.content(espruino.log()))
          .timeout(config.deployTimeout, "Deploy timed out after #{config.deployTimeout} milliseconds.")
          .fail((error) -> publish.error("gulp-espruino found an error, barfing. #{error}\nLog: #{espruino.log()}"))
          .finally(-> espruino.close())
          .done()

# Todo.
# blow up if not stream
# add in hook to finish stream slurp whenever you want
# continue emit errors
# versioning
