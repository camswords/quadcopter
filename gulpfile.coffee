gulp = require 'gulp'
gutil = require 'gulp-util'
espruino = require './gulp-espruino/src/gulp-espruino'
requireDir = require 'require-dir'
gulps = requireDir './src/tasks'

gulp.task 'default', ['test']

gulp.task 'clean', -> gulps.clean()

gulp.task 'performance', ['clean'], ->
  gulps.performance
    espruino: { connection: { fakePath: '../Espruino/espruino' }}

gulp.task 'deploy', ['clean'], ->
  gulps.application(configuration: 'release')
       .pipe espruino.deploy(connection: { findFirst: true })
       .on 'data', (data) -> gutil.log(data.contents.toString())

gulp.task 'test', ['clean'], ->
  gulps.tests(configuration: 'test')
       .pipe espruino.deploy(connection: { fakePath: '../Espruino/espruino' })
       .on 'data', (data) -> gutil.log(data.contents.toString())
       .pipe espruino.deploy(connection: { fakePath: '../Espruino/espruino' })
       .on 'data', (data) -> gutil.log(data.contents.toString())
