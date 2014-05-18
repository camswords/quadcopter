gulp = require 'gulp'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
gulpif = require 'gulp-if'
extend = require 'extend'
gutil = require 'gulp-util'
minify = require './minify'
optimiseAmd = require '../../gulp-amd-optimise/src/amd-optimise'

module.exports = (overrides) ->
  defaults =
    configuration: 'test'
    additionalSourceFiles: []
    optimiseAmd: false
  options = extend({}, defaults, overrides)

  src = []

  if !options.optimiseAmd
    src.push('./src/main/utility/deferred.coffee')
    src.push('./src/main/utility/amd.coffee')

  src.push("./src/configuration/#{options.configuration}.coffee")
  src.push('./src/main/**/*.coffee')

  gulp.src(src.concat(options.additionalSourceFiles))
      .pipe gulpif(/[.]coffee/, coffee(bare: true).on('error', gutil.log))
      .pipe concat('application-unminified.js')
      .pipe gulp.dest('build')
      .pipe gulpif(options.optimiseAmd, optimiseAmd().on('error', gutil.log))
      .pipe gulpif(options.optimiseAmd, concat('application-amd-optimised.js'))
      .pipe gulp.dest('build')
      .pipe minify()
      .pipe concat('application.js')
      .pipe gulp.dest('build')
