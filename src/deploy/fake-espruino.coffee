through = require 'through2'
extend = require 'extend'

digitalPulse = ->
digitalWrite = ->
LED1 = 1
LED2 = 2
LED3 = 3
A13 = 13
C6 = 6
C7 = 7
C8 = 8
C9 = 9
E = clip: -> 0
setWatch = ->

module.exports =
  deploy: (options) ->
    defaults =
      echoOn: false
      capture:
        output: false
        input: true

    config = extend({}, defaults, options)

    through.obj (file, encoding, callback) ->
      if file.isNull()
        @.push(file)
        callback()

      if file.isStream()
        @.push(null)
        callback('fake-espruino does not support streaming. Barfing.')

      if file.isBuffer()
        output = ""
        output += file.contents.toString() if config.capture.output
        output += file.contents.toString() if config.echoOn

        code =
        "(function safelyExecute() {
          var captured = '';

          var console = { log: function(message) { captured = captured + message; } };
          var setInterval = function(callback, time) {};
          var setTimeout = function(callback, time) {};" +
          file.contents.toString() +
          " return captured;
        })();"

        consoleOutput = eval(code)
        output += consoleOutput if config.capture.input

        file.contents = new Buffer(output)
        @.push(file)
        callback()



