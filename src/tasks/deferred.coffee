gulp = require 'gulp'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
gutil = require 'gulp-util'
gulpif = require 'gulp-if'

module.exports =
  test: ->
    gulp.src(['./src/main/deferred.coffee', './src/test/deferred-test.coffee'])
        .pipe gulpif(/[.]coffee/, coffee(bare: true).on('error', gutil.log))
        .pipe concat('deferred-tests.js')
        .pipe gulp.dest('build')
