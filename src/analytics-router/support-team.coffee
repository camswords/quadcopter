cursor = require('ansi')(process.stdout)
_ = require('lodash')
protocol = require('./protocol')

columnWidth = 30
metricsPerRow = 4
numberOfRows = Math.ceil(Object.keys(protocol.metrics).length / metricsPerRow)
consoleLinesPerRow = 4
metricsValueOffset = 7


initialise = ->
  for row in [1..numberOfRows * consoleLinesPerRow] by 1
    cursor.goto(1, row).eraseLine()


outputToConsole = (metrics) ->
  _.forEach Object.keys(protocol.metrics), (metricName, index) ->
    column = index % metricsPerRow
    row = Math.floor(index / metricsPerRow) + 1

    cursor.fg.reset()
    cursor.magenta()

    cursor.goto(column * columnWidth, (row * consoleLinesPerRow))
    cursor.eraseLine().write(metricName)

    cursor.fg.reset()
    cursor.green()

    cursor.goto(column * columnWidth + metricsValueOffset, (row * consoleLinesPerRow) + 1)

    if (metrics[metricName] == undefined || metrics[metricName] == null)
      cursor.fg.reset()
      cursor.red()
      cursor.eraseLine().write('-')
    else
      cursor.fg.reset()
      cursor.green()
      cursor.eraseLine().write(metrics[metricName] + "")


module.exports =
  notify: outputToConsole
  initialise: initialise
