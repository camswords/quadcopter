gulp = require 'gulp'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'
concat = require 'gulp-concat'
order = require 'gulp-order'
gulpif = require 'gulp-if'
eventStream = require 'event-stream'
espruino = require './gulp-espruino/src/gulp-espruino'

application = ->
  gulp.src(['./src/lib/requirejs-*.js',
            './src/main/**/*.coffee'])
  .pipe gulpif(/[.]coffee/, coffee(bare: true).on('error', gutil.log))
  .pipe concat('application.js')

tests = ->
  gulp.src(['./src/test/Squire*.js',
            './src/test/mini-test.coffee',
            './src/test/**/*.coffee'])
  .pipe gulpif(/[.]coffee/, coffee(bare: true).on('error', gutil.log))
  .pipe concat('tests.js')

gulp.task 'default', ['test']

gulp.task 'deploy', ->
  application()
    .pipe espruino.deploy(serialNumber: '48DF67773330', fakePath: '/Users/camswords/dev/quadcopter/Espruino/espruino')
    .on 'data', (data) -> gutil.log(data.contents.toString())

gulp.task 'test', ->
  eventStream.merge(application(), tests())
  .pipe order(['**/application.js', '**/tests.js'])
  .pipe concat('all.js')
  .pipe espruino.deploy(serialNumber: '48DF67773330', echoOn: false, capture: { output: false, input: true })
  .on 'data', (data) -> gutil.log(data.contents.toString())
