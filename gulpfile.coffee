gulp = require 'gulp'
gulps = require('require-dir')('./src/tasks')

gulp.task 'default', ['test']
gulp.task 'clean', -> gulps['clean']()

gulp.task 'test', ['test-optimise-amd', 'test-amd', 'test-deferred', 'test-unit']
gulp.task 'test-unit', ['clean'], -> gulps['test-unit']()
gulp.task 'test-deferred', ['clean'], -> gulps['test-deferred']()
gulp.task 'test-amd', ['clean'], -> gulps['test-amd']()
gulp.task 'test-optimise-amd', ['clean'], -> gulps['test-optimise-amd']()

gulp.task 'performance', ['performance-defined', 'performance-running']
gulp.task 'performance-defined', ['clean'], -> gulps['performance-defined']()
gulp.task 'performance-running', ['clean'], -> gulps['performance-running']()

gulp.task 'deploy', ['clean'], -> gulps['deploy']()
