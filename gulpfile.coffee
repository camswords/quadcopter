gulp = require 'gulp'
gulps = require('require-dir')('./src/tasks')

gulp.task 'watch-analytics-ftdi', -> gulps['watch-analytics-ftdi']()
gulp.task 'analytics-server', -> gulps['analytics-server']()

gulp.task 'analytics', ['watch-analytics-ftdi', 'analytics-server']
