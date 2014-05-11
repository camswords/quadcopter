gulp = require 'gulp'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
gutil = require 'gulp-util'
gulpif = require 'gulp-if'

module.exports =
  test: ->
    gulp.src(['./src/main/deferred.coffee',
              './src/main/modules.coffee',
              './src/test/modules-test.coffee'])
        .pipe gulpif(/[.]coffee/, coffee(bare: true).on('error', gutil.log))
        .pipe concat('modules-tests.js')
        .pipe gulp.dest('build')
