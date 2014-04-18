gulp = require 'gulp'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'
concat = require 'gulp-concat'
order = require 'gulp-order'
gulpif = require 'gulp-if'
clean = require 'gulp-clean'
eventStream = require 'event-stream'
espruino = require './gulp-espruino/src/gulp-espruino'

application = ->
  gulp.src(['./src/lib/almond-*.js',
            './src/main/**/*.coffee'])
  .pipe gulpif(/[.]coffee/, coffee(bare: true).on('error', gutil.log))
  .pipe concat('application.js')

tests = ->
  gulp.src(['./src/test/mini-test.coffee',
            './src/test/**/*.coffee'])
  .pipe gulpif(/[.]coffee/, coffee(bare: true).on('error', gutil.log))
  .pipe concat('tests.js')

gulp.task 'default', ['test']

gulp.task 'clean', -> gulp.src('build').pipe(clean())

gulp.task 'deploy', ['clean'], ->
  application()
    .pipe gulp.dest('build')
    .pipe espruino.deploy(
            serialNumber: '48DF67773330'
            idleReadTimeBeforeClose: 1000
            echoOn: true
            capture:
              input: true
              output: false
            fakePath: '../Espruino/espruino')
    .on 'data', (data) -> gutil.log(data.contents.toString())

gulp.task 'test', ->
  eventStream.merge(application(), tests())
  .pipe order(['**/application.js', '**/tests.js'])
  .pipe concat('all.js')
  .pipe espruino.deploy(
          serialNumber: '48DF67773330'
          echoOn: true
          capture:
            input: true
            output: false
          fakePath: '../Espruino/espruino')
  .on 'data', (data) -> gutil.log(data.contents.toString())
