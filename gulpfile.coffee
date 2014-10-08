gulp = require 'gulp'
gulps = require('require-dir')('./src/tasks')

gulp.task 'analytics-router', -> gulps['analytics-router']()
gulp.task 'analytics-server', -> gulps['analytics-server']()

gulp.task 'analytics', ['analytics-router', 'analytics-server']
