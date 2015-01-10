cursor = require('ansi')(process.stdout)
_ = require('lodash')
protocol = require('./protocol')

columnWidth = 30
metricsPerRow = 4
numberOfRows = Math.ceil(Object.keys(protocol.metrics).length / metricsPerRow)
consoleLinesPerRow = 4
metricsValueOffset = 7


initialise = ->
  for row in [1..(numberOfRows * consoleLinesPerRow) + 10] by 1
    cursor.goto(1, row).eraseLine()


outputToConsole = (representativeModel) ->
  _.forEach Object.keys(protocol.metrics), (metricName, index) ->
    column = index % metricsPerRow
    row = Math.floor(index / metricsPerRow) + 1

    cursor.magenta()

    cursor.goto(column * columnWidth, (row * consoleLinesPerRow))
    cursor.eraseLine().write(metricName)

    cursor.green()

    cursor.goto(column * columnWidth + metricsValueOffset, (row * consoleLinesPerRow) + 1)

    if representativeModel[metricName] == undefined || representativeModel[metricName] == null
      cursor.red()
      cursor.eraseLine().write('-')
    else if representativeModel[metricName].isStale()
      cursor.red()
      cursor.eraseLine().write(representativeModel[metricName].value + "")
    else
      cursor.green()
      cursor.eraseLine().write(representativeModel[metricName].value + "")

    cursor.reset()



module.exports =
  notify: outputToConsole
  initialise: initialise
