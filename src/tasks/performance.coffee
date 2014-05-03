gulp = require 'gulp'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'
concat = require 'gulp-concat'
gulpif = require 'gulp-if'
glob = require 'glob'
async = require 'async'
espruino = require '../../gulp-espruino/src/gulp-espruino'
Table = require 'cli-table'

howMuchMemory = (sourceFile, callback) ->
  gulp.src(['./src/main/lib/almond-*.js',
            './src/performance/memory/before.coffee',
            sourceFile,
            './src/performance/memory/after.coffee'])
      .pipe gulpif(/[.]coffee/, coffee(bare: true).on('error', gutil.log))
      .pipe concat('all.js')
      .pipe gulp.dest('build')
      .pipe espruino.deploy(
        serialNumber: '48DF67773330'
        echoOn: true
        capture:
          input: true
          output: false
        fakePath: '../Espruino/espruino')
      .on 'data', (data) ->
        matches = /memory used: (.*)/.exec(data.contents.toString())

        if matches && matches.length > 1
          callback(null, sourceFile: sourceFile, memoryUsage: parseInt(matches[1]))
        else
          callback("failed to determine memory for #{sourceFile}")

printResults = (results) ->
  table = new Table(head: ['Source File', 'Memory Usage (blocks)'], colWidths: [50, 25])
  total = 0
  for result in results
    table.push([result.sourceFile, result.memoryUsage])
    total += result.memoryUsage

  table.push(['Total', total])

  gutil.log(table.toString())


module.exports = ->
  files = glob.sync('./src/main/**/*.coffee')

  async.mapSeries files, howMuchMemory, (error, results) ->
    if error
      gutil.log("failed!", error)
    else
      printResults(results)
