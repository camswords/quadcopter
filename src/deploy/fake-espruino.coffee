through = require 'through2'
extend = require 'extend'
fs = require 'fs'
exec = require('child_process').exec
tempFile = require('temp').track()

espruinoGlobals = "
var digitalPulse = function() {};
var digitalWrite = function() {};
var LED1 = 1;
var LED2 = 2;
var LED3 = 3;
var A13 = 13;
var C6 = 6;
var C7 = 7;
var C8 = 8;
var C9 = 9;
var E = {
  clip: function() { return 0; }
};
var setWatch = function() {};
"

module.exports =
  deploy: (options) ->
    defaults =
      echoOn: false
      capture:
        output: false
        input: true

    config = extend({}, defaults, options)

    through.obj (file, encoding, callback) ->
      stream = @

      if file.isNull()
        stream.push(file)
        callback()

      if file.isStream()
        stream.push(null)
        callback('fake-espruino does not support streaming. Barfing.')

      if file.isBuffer()
        output = ""
        output += file.contents.toString() if config.capture.output
        output += file.contents.toString() if config.echoOn

        tempFile.open 'fake-espruino-deployment', (openFileError, tempFile) ->
          if openFileError
            stream.push(null)
            callback("fake-espruino: failed to open temporary file due to #{openFileError}")
          else
            fs.write(tempFile.fd, espruinoGlobals)
            fs.write(tempFile.fd, file.contents.toString())
            fs.close tempFile.fd, (closeError) ->
              if closeError
                stream.push(null)
                callback("fake-espruino: failed to close temporary file due to #{closeError}")
              else
                exec "node #{tempFile.path} 2>&1", (execError, stdout) ->
                  if execError
                    stream.push(null)
                    callback("fake-espruino: failed to execute code due to #{execError}")
                  else
                    output += stdout if config.capture.input
                    file.contents = new Buffer(output)
                    stream.push(file)
                    callback()
