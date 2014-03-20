gulp = require 'gulp'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
espruino = require './gulp-espruino/src/gulp-espruino'
miniTest = require './src/deploy/gulp-mini-test'

gulp.task 'default', ['test']

gulp.task 'deploy', ->
  gulp.src './src/main/**/*.coffee'
      .pipe coffee(bare: true).on('error', gutil.log)
      .pipe concat('app.js')
      .pipe uglify()
      .pipe espruino.deploy(serialNumber: '48DF67773330')
    .on 'data', (data) -> gutil.log(data.contents.toString())

gulp.task 'test', ->
  gulp.src ['./src/main/**/*.coffee', './src/test/**/*.coffee']
      .pipe coffee(bare: true).on('error', gutil.log)
      .pipe concat('tests.js')
      .pipe uglify()
      .pipe espruino.deploy(serialNumber: '48DF67773330', echoOn: false, capture: { output: false, input: true })
      .pipe miniTest.checkResults()
    .on 'error', (error) ->
      gutil.log(error)
      process.exit(1)
