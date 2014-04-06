gulp = require 'gulp'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'
concat = require 'gulp-concat'
order = require 'gulp-order'
eventStream = require 'event-stream'
espruino = require './gulp-espruino/src/gulp-espruino'
fakeEspruino = require './src/deploy/fake-espruino'

application = ->
  eventStream.merge(
    gulp.src('./src/lib/almond-0.2.9.js'),
    gulp.src('./src/main/**/*.coffee')
      .pipe coffee(bare: true).on('error', gutil.log)
      .pipe concat('quadcopter.js'))
  .pipe order(['**/almond*.js', '**/quadcopter.js'])
  .pipe concat('application.js')


gulp.task 'default', ['test']

gulp.task 'deploy', ->
  application()
    .pipe fakeEspruino.deploy(serialNumber: '48DF67773330')
    .on 'data', (data) -> gutil.log(data.contents.toString())

gulp.task 'test', ->
  eventStream.merge(
    application(),
    gulp.src(['./src/test/mini-test.coffee', './src/test/**/*.coffee'])
      .pipe coffee(bare: true).on('error', gutil.log)
      .pipe concat('test.js')
  )
  .pipe order(['**/application.js', '**/tests.js'])
  .pipe concat('all.js')
  .pipe fakeEspruino.deploy(serialNumber: '48DF67773330', echoOn: false, capture: { output: false, input: true })
  .on 'data', (data) -> gutil.log(data.contents.toString())
