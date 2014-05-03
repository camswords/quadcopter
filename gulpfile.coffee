gulp = require 'gulp'
gutil = require 'gulp-util'
espruino = require './gulp-espruino/src/gulp-espruino'
requireDir = require('require-dir')
gulps = requireDir('./src/tasks')

gulp.task 'default', ['test']
gulp.task 'clean', -> gulps.clean()
gulp.task 'performance', ['clean'], -> gulps.performance()

gulp.task 'deploy', ['clean'], ->
  gulps.application()
       .pipe espruino.deploy(
          serialNumber: '48DF67773330'
          idleReadTimeBeforeClose: 1000
          echoOn: true
          capture:
            input: true
            output: false)
       .on 'data', (data) -> gutil.log(data.contents.toString())

gulp.task 'test', ['clean'], ->
  gulps.tests()
       .pipe espruino.deploy(
          serialNumber: '48DF67773330'
          echoOn: true
          capture:
            input: true
            output: false
          fakePath: '../Espruino/espruino')
       .on 'data', (data) -> gutil.log(data.contents.toString())
