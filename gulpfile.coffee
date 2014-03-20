gulp = require 'gulp'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
Combine = require 'stream-combiner'
espruino = require './gulp-espruino/src/gulp-espruino'
miniTest = require './src/deploy/gulp-mini-test'

gulp.task 'default', ['test']

gulp.task 'deploy', ->
  Combine(gulp.src('./src/main/**/*.coffee'),
          coffee(bare: true),
          concat('app.js'),
          uglify(),
          espruino.deploy(serialNumber: '48DF67773330'))
    .on 'error', gutil.log

gulp.task 'test', ->
  Combine(gulp.src(['./src/main/**/*.coffee', './src/test/**/*.coffee']),
          coffee(bare: true),
          concat('tests.js'),
          uglify(),
          espruino.deploy(serialNumber: '48DF67773330'),
          miniTest.checkResults())
    .on 'error', gutil.log


