gulp = require 'gulp'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
gulpif = require 'gulp-if'
extend = require 'extend'
gutil = require 'gulp-util'
minify = require './minify'

module.exports = (overrides) ->
  defaults = excludeStartupScript: false
  options = extend({}, defaults, overrides)

  src = []
  src.push('./src/main/espruino/hacks.coffee')
  src.push('./src/main/lib/almond-*.js')
  src.push('!./src/main/application.coffee') if options.excludeStartupScript
  src.push('./src/main/**/*.coffee')

  gulp.src(src)
      .pipe gulpif(/[.]coffee/, coffee(bare: true).on('error', gutil.log))
      .pipe concat('application-unminified.js')
      .pipe gulp.dest('build')
      .pipe minify()
      .pipe concat('application.js')
      .pipe gulp.dest('build')
