gulp = require 'gulp'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
espruino = require './src/deploy/gulp-espruino-fake'
miniTest = require './src/deploy/gulp-mini-test'

gulp.task 'default', ->
  gulp.src('./src/main/**/*.coffee')
    .pipe(coffee(bare: true).on('error', gutil.log))
    .pipe(concat('app.js'))
    .pipe(uglify())
    .pipe(espruino.deploy(port: '/dev/tty.usbmodem1421').on('error', gutil.log))

gulp.task 'test', ->
  gulp.src(['./src/main/**/*.coffee', './src/test/**/*.coffee'])
    .pipe(coffee(bare: true).on('error', gutil.log))
    .pipe(concat('tests.js'))
    .pipe(uglify())
    .pipe(espruino.deploy(port: '/dev/tty.usbmodem1421').on('error', gutil.log))
    .pipe(miniTest.checkResults())

