gulp = require 'gulp'
gulps = require('require-dir')('./src/tasks')

gulp.task 'default', ['test']
gulp.task 'clean', -> gulps['clean']()

gulp.task 'test', ['test-module', 'test-deferred', 'test-unit']
gulp.task 'test-unit', ['clean'], -> gulps['test-unit']()
gulp.task 'test-deferred', ['clean'], -> gulps['test-deferred']()
gulp.task 'test-module', ['clean'], -> gulps['test-module']()

gulp.task 'performance', ['performance-defined', 'performance-running']
gulp.task 'performance-defined', ['clean'], -> gulps['performance-defined']()
gulp.task 'performance-running', ['clean'], -> gulps['performance-running']()

gulp.task 'deploy', ['clean'], -> gulps['deploy']()
