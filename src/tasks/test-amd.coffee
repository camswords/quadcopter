gulp = require 'gulp'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
gutil = require 'gulp-util'
gulpif = require 'gulp-if'
espruino = require '../../gulp-espruino/src/gulp-espruino'

module.exports = ->
  gulp.src(['./src/main/utility/deferred.coffee',
            './src/main/utility/amd.coffee',
            './src/test/utility/amd-test.coffee'])
      .pipe gulpif(/[.]coffee/, coffee(bare: true).on('error', gutil.log))
      .pipe concat('amd-tests.js')
      .pipe gulp.dest('build')
      .pipe espruino.deploy(connection: { fakePath: '../Espruino/espruino' })
      .on 'data', (data) -> gutil.log(data.contents.toString())
