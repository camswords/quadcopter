gulp = require 'gulp'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'

gulp.task 'default', ->
  gulp.src('./src/main/**/*.coffee')
    .pipe(coffee(bare: true).on('error', gutil.log))
    .pipe(concat('quadcopter.js'))
    .pipe(uglify())
    .pipe(gulp.dest('./build/'))

