through = require 'through2'
gutil = require 'gulp-util'

module.exports =
  checkResults: ->
    numberOfTests = 0
    failedTests = 0

    gutil.log("Running tests...")

    onChunk = (content, encoding, callback) ->

      for testOutput in content.split('\n')
        if testOutput.match(/passed:/)
          numberOfTests++
          gutil.log('  ' + gutil.colors.green(testOutput))
        if testOutput.match(/failed:/)
          numberOfTests++
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
