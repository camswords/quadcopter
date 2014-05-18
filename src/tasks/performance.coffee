application = require './application'
espruino = require '../../gulp-espruino/src/gulp-espruino'
gutil = require 'gulp-util'

module.exports = ->
  application
    configuration: 'performance'
    additionalSourceFiles: ['./src/performance/sample-running-quadcopter.coffee']
    optimiseAmd: true
    recordMemoryUsage: true

  .pipe espruino.deploy(connection: { fakePath: '../Espruino/espruino' })
    .on 'data', (data) -> gutil.log(data.contents.toString())
