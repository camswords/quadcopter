gulp = require 'gulp'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'
concat = require 'gulp-concat'
espruino = require './gulp-espruino/src/gulp-espruino'
fakeEspruino = require './src/deploy/fake-espruino'

gulp.task 'default', ['test']

gulp.task 'deploy', ->
  gulp.src './src/main/**/*.coffee'
      .pipe coffee(bare: true).on('error', gutil.log)
      .pipe concat('app.js')
      .pipe fakeEspruino.deploy(serialNumber: '48DF67773330')
    .on 'data', (data) -> gutil.log(data.contents.toString())

gulp.task 'test', ->
  gulp.src ['./src/test/mini-test.coffee', './src/main/**/*.coffee', './src/test/**/*.coffee']
      .pipe coffee(bare: true).on('error', gutil.log)
      .pipe concat('tests.js')
      .pipe fakeEspruino.deploy(serialNumber: '48DF67773330', echoOn: false, capture: { output: false, input: true })
    .on 'data', (data) ->
      console.log(data.contents.toString())
