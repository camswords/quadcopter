gulp = require 'gulp'
gutil = require 'gulp-util'
espruino = require './gulp-espruino/src/gulp-espruino'
requireDir = require 'require-dir'
gulps = requireDir './src/tasks'

fake = connection: { fakePath: '../Espruino/espruino' }

gulp.task 'default', ['test']

gulp.task 'clean', -> gulps['clean']

gulp.task 'test-unit', ['clean'], -> gulps['test-unit']()
gulp.task 'test-deferred', ['clean'], -> gulps['deferred']()
gulp.task 'test-module', ['clean'], -> gulps['modules']()

gulp.task 'performance-defined', ['clean'], -> gulps['defined-memory']()
gulp.task 'performance-running', ['clean'], -> gulps['running-memory']()

gulp.task 'deploy', ['clean'], -> gulps['deploy']()
