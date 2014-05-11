gulp = require 'gulp'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
gulpif = require 'gulp-if'
extend = require 'extend'
gutil = require 'gulp-util'
minify = require './minify'

module.exports = (overrides) ->
  defaults =
    excludeStartupScript: false
    configuration: 'local'
    additionalSourceFiles: []
  options = extend({}, defaults, overrides)

  src = []
  src.push('./src/main/espruino/hacks.coffee')
  src.push('./src/main/deferred.coffee')
  src.push('./src/main/modules.coffee')
  src.push("./src/configuration/#{options.configuration}.coffee")
  src.push('!./src/main/application.coffee') if options.excludeStartupScript
  src.push('./src/main/**/*.coffee')

  gulp.src(src.concat(options.additionalSourceFiles))
      .pipe gulpif(/[.]coffee/, coffee(bare: true).on('error', gutil.log))
      .pipe concat('application-unminified.js')
      .pipe gulp.dest('build')
      .pipe minify()
      .pipe concat('application.js')
      .pipe gulp.dest('build')
