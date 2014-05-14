application = require './application'
espruino = require '../../gulp-espruino/src/gulp-espruino'
gutil = require 'gulp-util'

module.exports = ->
  application
    configuration: 'performance'
    excludeStartupScript: true
    additionalSourceFiles: [
      './src/performance/instrument-memory-usage.coffee',
      './src/performance/sample-running-quadcopter.coffee']
  .pipe espruino.deploy(connection: { fakePath: '../Espruino/espruino' })
    .on 'data', (data) -> gutil.log(data.contents.toString())
