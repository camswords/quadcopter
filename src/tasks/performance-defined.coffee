gulp = require 'gulp'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'
concat = require 'gulp-concat'
gulpif = require 'gulp-if'
glob = require 'glob'
async = require 'async'
Table = require 'cli-table'
Q = require 'q'
espruino = require '../../gulp-espruino/src/gulp-espruino'
minify = require './minify'

howMuchMemory = (options, sourceFile, sourceFiles, callback) ->
  gulp.src(sourceFiles)
      .pipe gulpif(/[.]coffee/, coffee(bare: true).on('error', gutil.log))
      .pipe concat('performance-unminified.js')
      .pipe gulp.dest('build')
      .pipe minify()
      .pipe concat('performance.js')
      .pipe gulp.dest('build')
      .pipe espruino.deploy(connection: { fakePath: '../Espruino/espruino' })
      .on 'data', (data) ->
        matches = /memory used: (.*)/.exec(data.contents.toString())

        if matches && matches.length > 1
          callback(null, sourceFile: sourceFile, memoryUsage: parseInt(matches[1]))
        else
          callback("failed to determine memory for #{sourceFile}")

howMuchMemoryForAMD = (options, callback) ->
    howMuchMemory(options
                  './src/main/utility/amd.coffee',
                  ['./src/performance/sample-memory-before.coffee',
                   './src/main/utility/amd.coffee',
                   './src/performance/sample-memory-after.coffee'],
                  callback)

howMuchMemoryForDeferred = (options, callback) ->
    howMuchMemory(options
                  './src/main/deferred.coffee',
                  ['./src/performance/sample-memory-before.coffee',
                   './src/main/deferred.coffee',
                   './src/performance/sample-memory-after.coffee'],
                  callback)

howMuchMemoryForFile = (options) ->
  (sourceFile, callback) ->
    howMuchMemory(options,
                  sourceFile,
                  ['./src/main/deferred.coffee',
                   './src/main/utility/amd.coffee',
                   './src/performance/sample-memory-before.coffee',
                   sourceFile,
                   './src/performance/sample-memory-after.coffee'],
                  callback)

formatResults = (results) ->
  table = new Table(head: ['Source File', 'Memory Usage (blocks)'], colWidths: [50, 25])
  total = 0
  sortedResults = results.sort((a, b) -> a.memoryUsage - b.memoryUsage)

  for result in sortedResults
    table.push([result.sourceFile, result.memoryUsage])
    total += result.memoryUsage

  table.push(['Total', total])
  table.toString()

module.exports = (options) ->
  files = glob.sync('./src/main/**/*.coffee').filter (fileName) ->
    fileName != './src/main/utility/amd.coffee' &&
    fileName != './src/main/deferred.coffee'

  amdMemoryMeasured = Q.denodeify(howMuchMemoryForAMD)(options)
  deferredMemoryMeasured = Q.denodeify(howMuchMemoryForDeferred)(options)
  eachFileMemoryMeasured = Q.denodeify(async.mapSeries)(files, howMuchMemoryForFile(options))

  Q.all([eachFileMemoryMeasured, amdMemoryMeasured, deferredMemoryMeasured])
    .spread (fileResults, amdResults, deferredResults) ->
      gutil.log formatResults(fileResults.concat([amdResults, deferredResults]))
    .done()
