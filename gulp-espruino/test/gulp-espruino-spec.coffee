proxyquire = require 'proxyquire'
through = require('through2')
StringStream = require('string-stream')

serialPortBuilder = ->
  communications = []
  communicationsConducted = 0

  builder =
    on: (options) ->
      communications.push(options)
      builder
    build: ->
      onData = ->

      serialPort =
        write: (command) ->
          communication = communications[communicationsConducted++]

          if command.match communication.receive
            setTimeout((-> onData(communication.send)))
          else
            console.log "failed to receive expected command #{communication.receive}, instead received #{command}"

        on: (eventName, callback) -> onData = callback if eventName == 'data'
        open: (callback) -> callback()
        close: (callback) -> callback()
        SerialPort: -> serialPort

  builder

describe 'espruino', ->
  it 'should save once code has been written', (done) ->
    serialPort = serialPortBuilder()
      .on(receive: /reset/, send: 'ESPRUINO v3.1')
      .on(receive: /echo.0./, send: 'done')
      .on(receive: /duuuude/, send: 'done')
      .on(receive: /echo.1./, send: 'done')
      .on(receive: /save/, send: 'Checking...\nDone!')
      .build()

    espruino = proxyquire('../src/gulp-espruino', 'serialport': serialPort)

    new StringStream('duuuude')
      .pipe(espruino.deploy('myport', idleReadTimeBeforeClose: 100))
      .pipe through (chunk, encoding, callback) ->
        this.push(null)
        callback()
        done()

  it 'should make all of the output available for the next stream', (done) ->
    serialPort = serialPortBuilder()
      .on(receive: /reset/, send: 'ESPRUINO v3.1\n')
      .on(receive: /echo.0./, send: 'echo off\n')
      .on(receive: /code/, send: 'code uploaded\n')
      .on(receive: /echo.1./, send: 'echo on\n')
      .on(receive: /save/, send: 'saved!')
      .build()

    espruino = proxyquire('../src/gulp-espruino', 'serialport': serialPort)

    new StringStream('code')
      .pipe(espruino.deploy('myport', idleReadTimeBeforeClose: 100))
      .pipe through (chunk, encoding, callback) ->
        expect(chunk.toString()).toBe('ESPRUINO v3.1\necho off\ncode uploaded\necho on\nsaved!')
        this.push(null)
        callback()
        done()

  it 'should ignore save when specified', (done) ->
    serialPort = serialPortBuilder()
      .on(receive: /reset/, send: 'ESPRUINO v3.1\n')
      .on(receive: /echo.0./, send: 'echo off\n')
      .on(receive: /code/, send: 'code uploaded\n')
      .on(receive: /echo.1./, send: 'echo on\n')
      .build()

    espruino = proxyquire('../src/gulp-espruino', 'serialport': serialPort)

    new StringStream('code')
      .pipe(espruino.deploy('myport', idleReadTimeBeforeClose: 100, save: false))
      .pipe through (chunk, encoding, callback) ->
        this.push(null)
        callback()
        done()

  it 'should ignore reset when specified', (done) ->
    serialPort = serialPortBuilder()
      .on(receive: /echo.0./, send: 'echo off\n')
      .on(receive: /code/, send: 'code uploaded\n')
      .on(receive: /echo.1./, send: 'echo on\n')
      .on(receive: /save/, send: 'saved!')
      .build()

    espruino = proxyquire('../src/gulp-espruino', 'serialport': serialPort)

    new StringStream('code')
      .pipe(espruino.deploy('myport', idleReadTimeBeforeClose: 100, reset: false))
      .pipe through (chunk, encoding, callback) ->
        this.push(null)
        callback()
        done()

  it 'should ignore echo when specified', (done) ->
    serialPort = serialPortBuilder()
      .on(receive: /reset/, send: 'ESPRUINO v3.1\n')
      .on(receive: /code/, send: 'code uploaded\n')
      .on(receive: /save/, send: 'saved!')
      .build()

    espruino = proxyquire('../src/gulp-espruino', 'serialport': serialPort)

    new StringStream('code')
      .pipe(espruino.deploy('myport', idleReadTimeBeforeClose: 100, echoOff: false))
      .pipe through (chunk, encoding, callback) ->
        this.push(null)
        callback()
        done()
