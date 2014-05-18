application = require './application'
espruino = require '../../gulp-espruino/src/gulp-espruino'
gutil = require 'gulp-util'

module.exports = ->
  application(configuration: 'release', optimiseAmd: true)
    .pipe espruino.deploy(connection: { findFirst: true })
    .on 'data', (data) -> gutil.log(data.contents.toString())
