gulp = require 'gulp'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
espruino = require './src/deploy/gulp-espruino'

gulp.task 'default', ->
  gulp.src('./src/main/**/*.coffee')
    .pipe(coffee(bare: true).on('error', gutil.log))
    .pipe(concat('../../build/quadcopter.js'))
    .pipe(uglify())
    .pipe(espruino.deploy('/dev/tty.usbmodem1421').on('error', gutil.log))

