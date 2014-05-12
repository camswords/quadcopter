gulp = require 'gulp'
gutil = require 'gulp-util'
espruino = require './gulp-espruino/src/gulp-espruino'
requireDir = require 'require-dir'
gulps = requireDir './src/tasks'

fake = connection: { fakePath: '../Espruino/espruino' }
performance =
  defined: -> gulps['defined-memory'](espruino: fake)
  running: -> gulps['running-memory'](espruino: fake)


gulp.task 'default', ['test']

gulp.task 'clean', -> gulps.clean()

gulp.task 'test', ['clean'], ->
  gulps.tests(configuration: 'test')
       .pipe espruino.deploy(fake)
       .on 'data', (data) -> gutil.log(data.contents.toString())

gulp.task 'performance-defined', ['clean'], -> performance.defined()
gulp.task 'performance-running', ['clean'], -> performance.running()

gulp.task 'deploy', ['clean'], ->
  gulps.application(configuration: 'release')
       .pipe espruino.deploy(connection: { findFirst: true })
       .on 'data', (data) -> gutil.log(data.contents.toString())

gulp.task 'test-deferred', ['clean'], ->
  gulps.deferred.test()
       .pipe espruino.deploy(connection: { fakePath: '../Espruino/espruino' })
       .on 'data', (data) -> gutil.log(data.contents.toString())

gulp.task 'test-module', ['clean'], ->
  gulps.modules.test()
       .pipe espruino.deploy(connection: { fakePath: '../Espruino/espruino' })
       .on 'data', (data) -> gutil.log(data.contents.toString())
