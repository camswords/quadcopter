through = require 'through2'
gutil = require 'gulp-util'

module.exports =
  deploy: (options) ->
    through.obj (chunk, encoding, callback) ->
      this.push('passed: some wonderful passing test')
      this.push('passed: another passing test')
      this.push('failed: should fail really')
      callback()
