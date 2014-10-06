# To run this, call gulp [task] --require coffee-script/register

gulp = require 'gulp'
gulps = require('require-dir')('./src/tasks')

gulp.task 'default', ['test']
gulp.task 'clean', -> gulps['clean']()

gulp.task 'test', ['test-optimise-amd', 'test-amd', 'test-deferred', 'test-unit']
gulp.task 'test-unit', ['clean'], -> gulps['test-unit']()
gulp.task 'test-deferred', ['clean'], -> gulps['test-deferred']()
gulp.task 'test-amd', ['clean'], -> gulps['test-amd']()
gulp.task 'test-optimise-amd', ['clean'], -> gulps['test-optimise-amd']()

gulp.task 'performance', ['clean'], -> gulps['performance']()
gulp.task 'watch-analytics-ftdi', ['clean'], -> gulps['watch-analytics-ftdi']()
gulp.task 'analytics-server', -> gulps['analytics-server']()
gulp.task 'analytics', ['watch-analytics-ftdi', 'analytics-server']

gulp.task 'deploy', ['clean'], -> gulps['deploy']()
