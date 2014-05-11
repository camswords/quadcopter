gulp = require 'gulp'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
gulpif = require 'gulp-if'
gutil = require 'gulp-util'
eventStream = require 'event-stream'
order = require 'gulp-order'
application = require './application'
extend = require 'extend'

module.exports = (overrides) ->
  testFiles = ->
    gulp.src(['./src/test/**/*.coffee',
              '!./src/test/**/deferred-test.coffee',
              '!./src/test/**/modules-test.coffee',
              '!./src/test/**/tests.coffee'])
        .pipe gulpif(/[.]coffee/, coffee(bare: true).on('error', gutil.log))
        .pipe concat('test-files.js')

  testRunner = ->
    gulp.src(['./src/test/**/tests.coffee'])
        .pipe gulpif(/[.]coffee/, coffee(bare: true).on('error', gutil.log))
        .pipe concat('test-runner.js')

  tests = eventStream.merge(testFiles(), testRunner())
    .pipe order(['test-files.js', 'test-runner.js'])
    .pipe concat('tests.js')
    .pipe gulp.dest('build')

  defaults =
    excludeStartupScript: true
    configuration: 'local'

  options = extend({}, defaults, overrides)

  eventStream.merge(application(options), tests)
    .pipe order(['**/application.js', '**/tests.js'])
    .pipe concat('all.js')
    .pipe gulp.dest('build')
