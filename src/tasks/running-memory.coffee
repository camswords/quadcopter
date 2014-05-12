application = require './application'
espruino = require '../../gulp-espruino/src/gulp-espruino'
gutil = require 'gulp-util'

module.exports = (options) ->
  application
    configuration: 'performance'
    excludeStartupScript: true
    additionalSourceFiles: ['./src/performance/sample-running-quadcopter.coffee']
  .pipe espruino.deploy(options.espruino)
    .on 'data', (data) -> gutil.log(data.contents.toString())
