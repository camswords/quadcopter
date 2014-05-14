gulp = require 'gulp'
gutil = require 'gulp-util'
espruino = require './gulp-espruino/src/gulp-espruino'
requireDir = require 'require-dir'
gulps = requireDir './src/tasks'

fake = connection: { fakePath: '../Espruino/espruino' }

gulp.task 'default', ['test']

gulp.task 'clean', -> gulps.clean()

gulp.task 'test', ['clean'], ->
  gulps.tests(configuration: 'test')
       .pipe espruino.deploy(fake)
       .on 'data', (data) -> gutil.log(data.contents.toString())

gulp.task 'performance-defined', ['clean'], -> gulps['defined-memory']()
gulp.task 'performance-running', ['clean'], -> gulps['running-memory']()

gulp.task 'deploy', ['clean'], ->
  gulps.application(configuration: 'release')
       .pipe espruino.deploy(connection: { findFirst: true })
       .on 'data', (data) -> gutil.log(data.contents.toString())

gulp.task 'test-deferred', ['clean'], -> gulps['deferred']()
gulp.task 'test-module', ['clean'], -> gulps['modules']()
