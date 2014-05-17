through = require 'through2'
astFactory = require './ast'
modules = require './generate-modules'
order = require './order-defines'

module.exports = ->
  through.obj (file, encoding, callback) ->
    stream = @
#    if file.isNull()
#      publish.content(null)
#
#    if file.isStream()
#      publish.error('gulp-espruino does not support streaming. Barfing.')

    if file.isBuffer()
      ast = astFactory.build file.contents.toString()

      order ast.defines(), (error, ordered) ->
        sourceCode = modules.generate(ordered)
        file.contents = new Buffer(sourceCode)
        stream.push(file)
        callback()

