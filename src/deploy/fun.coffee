SerialPort = require('serialport').SerialPort
fs = require 'fs'
through = require 'through2'

serialPort = new SerialPort('/dev/tty.usbmodem1421', { baudrate: 9600 })

onSuccess = (chunk, encoding, callback) ->
  self = this

  publish = (->
    published = false

    content: (content) ->
      published = true
      self.push(content)
      callback()

    error: (error) ->
      published = true
      self.push(null)
      callback(error)

    published: -> published
  )()

  consume = (->
    consumed = ''
    timeout = null

    (content) ->
      consumed += content
      clearTimeout(timeout)
      timeout = setTimeout((-> publish.content(consumed) unless publish.published()), 1000)
  )()

  serialPort.on 'data', (data) -> consume(data.toString())

  serialPort.on 'error', (error) -> publish.error(null, error)

  serialPort.open ->
    serialPort.write chunk, (error) ->
      publish.error(error) if error

onFinish = (callback) ->
  self = this

  serialPort.close ->
    self.push(null)
    callback()

fs.createReadStream('./src/deploy/code.txt').pipe through(onSuccess, onFinish)
