gulp = require 'gulp'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
gulpif = require 'gulp-if'
gutil = require 'gulp-util'
eventStream = require 'event-stream'
order = require 'gulp-order'
application = require './application'
espruino = require '../../gulp-espruino/src/gulp-espruino'

module.exports = ->
  amdSetup = ->
    gulp.src(['./src/test/**/amd-setup.coffee'])
        .pipe gulpif(/[.]coffee/, coffee(bare: true).on('error', gutil.log))
        .pipe concat('amd-setup.js')

  testFiles = ->
    gulp.src(['./src/test/**/*.coffee',
              '!./src/test/**/deferred-test.coffee',
              '!./src/test/**/modules-test.coffee',
              '!./src/test/**/tests.coffee',
              '!./src/test/**/amd-setup.coffee'])
        .pipe gulpif(/[.]coffee/, coffee(bare: true).on('error', gutil.log))
        .pipe concat('test-files.js')

  testRunner = ->
    gulp.src(['./src/test/**/tests.coffee'])
        .pipe gulpif(/[.]coffee/, coffee(bare: true).on('error', gutil.log))
        .pipe concat('test-runner.js')

  tests = eventStream.merge(amdSetup(), testFiles(), testRunner())
    .pipe order(['amd-setup.js', 'test-files.js', 'test-runner.js'])
    .pipe concat('tests.js')
    .pipe gulp.dest('build')

  app = application(excludeStartupScript: true, configuration: 'test')
  eventStream.merge(app, tests)
    .pipe order(['**/application.js', '**/tests.js'])
    .pipe concat('all.js')
    .pipe gulp.dest('build')
    .pipe espruino.deploy(connection: { fakePath: '../Espruino/espruino' })
    .on 'data', (data) -> gutil.log(data.contents.toString())

