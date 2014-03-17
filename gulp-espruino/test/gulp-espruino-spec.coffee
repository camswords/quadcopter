proxyquire = require 'proxyquire'
through = require('through2')
util = require 'util'
Readable = require('stream').Readable

createCodeStream = (code) ->
  CodeStream = -> Readable.call(@, objectMode: true)

  util.inherits(CodeStream, Readable)

  CodeStream.prototype._read = ->
    this.push(code)
    this.push(null)

  new CodeStream(code)

serialPortBuilder = ->
  communications = []
  communicationsConducted = 0
  port = null
  availablePorts = []

  builder =
    on: (options) ->
      communications.push(options)
      builder
    withPorts: (_availablePorts) ->
      availablePorts = _availablePorts
      builder
    build: ->
      onData = ->

      serialPort =
        list: (callback) -> callback(null, availablePorts)
        port: -> port
        write: (command) ->
          communication = communications[communicationsConducted++]

          if command.match communication.receive
            setTimeout((-> onData(communication.send)))
          else
            console.log "failed to receive expected command #{communication.receive}, instead received #{command}"

        on: (eventName, callback) -> onData = callback if eventName == 'data'
        open: (callback) -> callback()
        close: (callback) -> callback()
        SerialPort: (_port, options) ->
          port = _port
          serialPort

  builder

describe 'espruino', ->
  it 'should save once code has been written', (done) ->
    serialPort = serialPortBuilder()
      .on(receive: /reset/, send: 'ESPRUINO v3.1')
      .on(receive: /echo.0./, send: 'done')
      .on(receive: /{ duuuude }/, send: 'done')
      .on(receive: /echo.1./, send: 'done')
      .on(receive: /save/, send: 'Checking...\nDone!')
      .build()

    espruino = proxyquire('../src/gulp-espruino', 'serialport': serialPort)

    createCodeStream(contents: new Buffer('duuuude'))
      .pipe(espruino.deploy(port: 'myport', idleReadTimeBeforeClose: 100))
      .pipe through (chunk, encoding, callback) ->
        this.push(null)
        callback()
        done()

  it 'should make all of the output available for the next stream', (done) ->
    serialPort = serialPortBuilder()
      .on(receive: /reset/, send: 'ESPRUINO v3.1\n')
      .on(receive: /echo.0./, send: 'echo off\n')
      .on(receive: /{ code }/, send: 'code uploaded\n')
      .on(receive: /echo.1./, send: 'echo on\n')
      .on(receive: /save/, send: 'saved!')
      .build()

    espruino = proxyquire('../src/gulp-espruino', 'serialport': serialPort)

    createCodeStream(contents: new Buffer('code'))
      .pipe(espruino.deploy(port: 'myport', idleReadTimeBeforeClose: 100))
      .pipe through (chunk, encoding, callback) ->
        expect(chunk.toString()).toBe('ESPRUINO v3.1\necho off\ncode uploaded\necho on\nsaved!')
        this.push(null)
        callback()
        done()

  it 'should ignore save when specified', (done) ->
    serialPort = serialPortBuilder()
      .on(receive: /reset/, send: 'ESPRUINO v3.1\n')
      .on(receive: /echo.0./, send: 'echo off\n')
      .on(receive: /{ code }/, send: 'code uploaded\n')
      .on(receive: /echo.1./, send: 'echo on\n')
      .build()

    espruino = proxyquire('../src/gulp-espruino', 'serialport': serialPort)

    createCodeStream(contents: new Buffer('code'))
      .pipe(espruino.deploy(port: 'myport', idleReadTimeBeforeClose: 100, save: false))
      .pipe through (chunk, encoding, callback) ->
        this.push(null)
        callback()
        done()

  it 'should ignore reset when specified', (done) ->
    serialPort = serialPortBuilder()
      .on(receive: /echo.0./, send: 'echo off\n')
      .on(receive: /{ code }/, send: 'code uploaded\n')
      .on(receive: /echo.1./, send: 'echo on\n')
      .on(receive: /save/, send: 'saved!')
      .build()

    espruino = proxyquire('../src/gulp-espruino', 'serialport': serialPort)

    createCodeStream(contents: new Buffer('code'))
      .pipe(espruino.deploy(port: 'myport', idleReadTimeBeforeClose: 100, reset: false))
      .pipe through (chunk, encoding, callback) ->
        this.push(null)
        callback()
        done()

  it 'should ignore echo when specified', (done) ->
    serialPort = serialPortBuilder()
      .on(receive: /reset/, send: 'ESPRUINO v3.1\n')
      .on(receive: /{ code }/, send: 'code uploaded\n')
      .on(receive: /save/, send: 'saved!')
      .build()

    espruino = proxyquire('../src/gulp-espruino', 'serialport': serialPort)

    createCodeStream(contents: new Buffer('code'))
      .pipe(espruino.deploy(port: 'myport', idleReadTimeBeforeClose: 100, echoOff: false))
      .pipe through (chunk, encoding, callback) ->
        this.push(null)
        callback()
        done()

  it 'should barf when there is no port or serial number supplied', (done) ->
    serialPort = serialPortBuilder().build()
    espruino = proxyquire('../src/gulp-espruino', 'serialport': serialPort)

    deployStream = espruino.deploy({})

    deployStream.on 'error', (error) ->
      expect(error).toBe('Espruino port or serial number is not specified. Barfing.')
      done()

    createCodeStream(contents: new Buffer('code')).pipe(deployStream)

  it 'should barf when time taken is longer than the timeout', (done) ->
    serialPort = serialPortBuilder()
      .on(receive: /reset/, send: 'ESPRUINO v3.1\n')
      .on(receive: /echo.0./, send: 'echo off\n')
      .on(receive: /{ code }/, send: 'code uploaded\n')
      .on(receive: /echo.1./, send: 'echo on\n')
      .on(receive: /save/, send: 'saved!')
      .build()

    espruino = proxyquire('../src/gulp-espruino', 'serialport': serialPort)
    deployStream = espruino.deploy(port: '/dev/port', deployTimeout: 100)

    deployStream.on 'error', (error) -> done()

    createCodeStream(contents: new Buffer('code')).pipe(deployStream)

  it 'should barf when the espruino with specified serialNumber cannot be found', (done) ->
    serialPort = serialPortBuilder()
      .withPorts([{ comName: '/my/other/serial/port', manufacturer: 'Acme', serialNumber: '1234' }])
      .build()
    espruino = proxyquire('../src/gulp-espruino', 'serialport': serialPort)

    deployStream = espruino.deploy(serialNumber: 'hahaha.not.present')

    deployStream.on 'error', (error) ->
      expect(error).toBe("Espruino with serial number 'hahaha.not.present' not found. Barfing." +
                         " We did find these ports: [{\"comName\":\"/my/other/serial/port\",\"manufacturer\":\"Acme\",\"serialNumber\":\"1234\"}].")
      done()

    createCodeStream(contents: new Buffer('code')).pipe(deployStream)

  it 'should barf when no configuration is supplied', (done) ->
    serialPort = serialPortBuilder().build()
    espruino = proxyquire('../src/gulp-espruino', 'serialport': serialPort)

    deployStream = espruino.deploy()

    deployStream.on 'error', (error) ->
      expect(error).toBe('Espruino port or serial number is not specified. Barfing.')
      done()

    createCodeStream(contents: new Buffer('code')).pipe(deployStream)

  it 'should find the espruino if the serial id is specified', (done) ->
    serialPort = serialPortBuilder()
      .on(receive: /reset/, send: 'ESPRUINO v3.1\n')
      .on(receive: /echo.0./, send: 'echo off\n')
      .on(receive: /{ code }/, send: 'code uploaded\n')
      .on(receive: /echo.1./, send: 'echo on\n')
      .on(receive: /save/, send: 'saved!')
      .withPorts([{ comName: '/my/other/serial/port', manufacturer: 'Acme', serialNumber: '1234' },
                  { comName: '/my/espruino/serial/port', manufacturer: 'STMicroelectronics', serialNumber: '48DF67773330' }
                 ])
      .build()

    espruino = proxyquire('../src/gulp-espruino', 'serialport': serialPort)

    createCodeStream(contents: new Buffer('code'))
      .pipe(espruino.deploy(serialNumber: '48DF67773330', idleReadTimeBeforeClose: 100))
      .pipe through (chunk, encoding, callback) ->
          expect(serialPort.port()).toBe('/my/espruino/serial/port')
          this.push(null)
          callback()
          done()
