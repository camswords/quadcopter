gulp = require 'gulp'
clean = require 'gulp-clean'

module.exports = -> gulp.src('build').pipe(clean())
