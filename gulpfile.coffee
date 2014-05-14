gulp = require 'gulp'
gulps = (require 'require-dir')('./src/tasks')

gulp.task 'default', ['test']
gulp.task 'clean', -> gulps['clean']

gulp.task 'test', ['test-module', 'test-deferred', 'test-unit']
gulp.task 'test-unit', ['clean'], -> gulps['test-unit']()
gulp.task 'test-deferred', ['clean'], -> gulps['deferred']()
gulp.task 'test-module', ['clean'], -> gulps['modules']()

gulp.task 'performance', ['performance-defined', 'performance-running']
gulp.task 'performance-defined', ['clean'], -> gulps['defined-memory']()
gulp.task 'performance-running', ['clean'], -> gulps['running-memory']()

gulp.task 'deploy', ['clean'], -> gulps['deploy']()
