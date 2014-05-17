gulp = require 'gulp'
mocha = require 'gulp-mocha'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'
gulpif = require 'gulp-if'
concat = require 'gulp-concat'

module.exports = ->
  gulp.src(['./gulp-amd-optimise/**/*.coffee'])
      .pipe gulpif(/[.]coffee/, coffee(bare: true).on('error', gutil.log))
      .pipe gulp.dest('build')
      .pipe mocha()
