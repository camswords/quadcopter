gulp = require 'gulp'
gutil = require 'gulp-util'
espruino = require './gulp-espruino/src/gulp-espruino'
requireDir = require('require-dir')
gulps = requireDir('./src/tasks')

gulp.task 'default', ['test']
gulp.task 'clean', -> gulps.clean()
gulp.task 'performance', ['clean'], ->
  gulps.performance
    espruino:
      serialNumber: '48DF67773330'
      fakePath: '../Espruino/espruino'

gulp.task 'deploy', ['clean'], ->
  gulps.application()
       .pipe espruino.deploy(serialNumber: '48DF67773330')
       .on 'data', (data) -> gutil.log(data.contents.toString())

gulp.task 'test', ['clean'], ->
  gulps.tests()
       .pipe espruino.deploy
          serialNumber: '48DF67773330',
          fakePath: '../Espruino/espruino'
       .on 'data', (data) -> gutil.log(data.contents.toString())
