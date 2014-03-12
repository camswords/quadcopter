through = require 'through2'
gutil = require 'gulp-util'

module.exports =
  checkResults: ->
    numberOfTests = 0
    failedTests = 0

    gutil.log("Running tests...")

    onChunk = (testOutput, encoding, callback) ->
      numberOfTests++

      if testOutput.match(/passed:/)
        gutil.log('  ' + gutil.colors.green(testOutput))

      if testOutput.match(/failed:/)
        failedTests++
        gutil.log('  ' + gutil.colors.red(testOutput))

      callback()

    onFinish = (callback) ->
      this.push(null)

      if failedTests == 0
        gutil.log("#{numberOfTests} test(s) passed successfully :)")
        callback()
      else
        callback("#{failedTests} of #{numberOfTests} test(s) failed :(")

    through(objectMode: true, onChunk, onFinish)
