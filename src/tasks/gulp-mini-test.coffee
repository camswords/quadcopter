through = require 'through2'
gutil = require 'gulp-util'

module.exports =
  checkResults: ->
    numberOfTests = 0
    failedTests = 0

    gutil.log("Running tests...")

    through.obj (file, encoding, callback) ->
      content = file.contents.toString()

      for testOutput in content.split('\n')
        if testOutput.match(/passed:/)
          numberOfTests++
          gutil.log('  ' + gutil.colors.green(testOutput))
        if testOutput.match(/failed:/)
          numberOfTests++
          failedTests++
          gutil.log('  ' + gutil.colors.red(testOutput))

      this.push(file)

      if failedTests == 0
        gutil.log("#{numberOfTests} test(s) passed successfully :)")
        callback()
      else
        callback("#{failedTests} of #{numberOfTests} test(s) failed :(")


