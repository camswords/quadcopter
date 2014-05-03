gulp = require 'gulp'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'
concat = require 'gulp-concat'
gulpif = require 'gulp-if'
glob = require 'glob'
async = require 'async'
espruino = require '../../gulp-espruino/src/gulp-espruino'
Table = require 'cli-table'

howMuchMemory = (options, sourceFile, sourceFiles, callback) ->
  gulp.src(sourceFiles)
      .pipe gulpif(/[.]coffee/, coffee(bare: true).on('error', gutil.log))
      .pipe concat('performance.js')
      .pipe gulp.dest('build')
      .pipe espruino.deploy(options.espruino)
      .on 'data', (data) ->
        matches = /memory used: (.*)/.exec(data.contents.toString())

        if matches && matches.length > 1
          callback(null, sourceFile: sourceFile, memoryUsage: parseInt(matches[1]))
        else
          callback("failed to determine memory for #{sourceFile}")

howMuchMemoryForAMD = (options, callback) ->
    howMuchMemory(options
                  './src/main/lib/almond-*.js',
                  ['./src/performance/memory/before.coffee',
                   './src/main/lib/almond-*.js',
                   './src/performance/memory/after.coffee'],
                  callback)

howMuchMemoryForFile = (options) ->
  (sourceFile, callback) ->
    howMuchMemory(options,
                  sourceFile,
                  ['./src/main/lib/almond-*.js',
                   './src/performance/memory/before.coffee',
                   sourceFile,
                   './src/performance/memory/after.coffee'],
                  callback)

formatResults = (results) ->
  table = new Table(head: ['Source File', 'Memory Usage (blocks)'], colWidths: [50, 25])
  total = 0
  for result in results
    table.push([result.sourceFile, result.memoryUsage])
    total += result.memoryUsage

  table.push(['Total', total])
  table.toString()

module.exports = (options) ->
  files = glob.sync('./src/main/**/*.coffee')

  howMuchMemoryForAMD options, (amdError, amdResults) ->
    if amdError
      gutil.log "error!", amdError
    else
      async.mapSeries files, howMuchMemoryForFile(options), (filesError, fileResults) ->
        if filesError
          gutil.log "error!", filesError
        else
          console.log formatResults(fileResults.concat([amdResults]))
