gulp = require 'gulp'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'
concat = require 'gulp-concat'
order = require 'gulp-order'
gulpif = require 'gulp-if'
clean = require 'gulp-clean'
eventStream = require 'event-stream'
extend = require 'extend'
espruino = require './gulp-espruino/src/gulp-espruino'

application = (overrides) ->
  defaults = excludeStartupScript: false
  options = extend({}, defaults, overrides)

  src = []
  src.push('./src/lib/almond-*.js')
  src.push('!./src/main/application.coffee') if options.excludeStartupScript
  src.push('./src/main/**/*.coffee')

  gulp.src(src)
      .pipe gulpif(/[.]coffee/, coffee(bare: true).on('error', gutil.log))
      .pipe concat('application.js')
      .pipe gulp.dest('build')

tests = ->
  testFiles = ->
    gulp.src(['./src/test/**/*.coffee', '!./src/test/**/tests.coffee'])
        .pipe gulpif(/[.]coffee/, coffee(bare: true).on('error', gutil.log))
        .pipe concat('test-files.js')

  testRunner = ->
    gulp.src(['./src/test/**/tests.coffee'])
        .pipe gulpif(/[.]coffee/, coffee(bare: true).on('error', gutil.log))
        .pipe concat('test-runner.js')

  eventStream.merge(testFiles(), testRunner())
    .pipe order(['**/application.js', '**/tests.js'])
    .pipe concat('tests.js')
    .pipe gulp.dest('build')


gulp.task 'default', ['test']

gulp.task 'clean', -> gulp.src('build').pipe(clean())

gulp.task 'deploy', ['clean'], ->
  application()
    .pipe espruino.deploy(
            serialNumber: '48DF67773330'
            idleReadTimeBeforeClose: 1000
            echoOn: true
            capture:
              input: true
              output: false
            fakePath: '../Espruino/espruino')
    .on 'data', (data) -> gutil.log(data.contents.toString())

gulp.task 'test', ['clean'], ->
  eventStream.merge(application(excludeStartupScript: true), tests())
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
