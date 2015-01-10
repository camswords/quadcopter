cursor = require('ansi')(process.stdout)
_ = require('lodash')
protocol = require('./protocol')

columnWidth = 30
metricsPerRow = 4
numberOfRows = Math.ceil(protocol.definitions.length / metricsPerRow)
consoleLinesPerRow = 4
metricsValueOffset = 7


initialise = ->
  for row in [1..(numberOfRows * consoleLinesPerRow) + 10] by 1
    cursor.goto(1, row).eraseLine()


outputToConsole = (representativeModel) ->
  _.forEach protocol.definitions, (definition, index) ->
    column = index % metricsPerRow
    row = Math.floor(index / metricsPerRow) + 1

    cursor.magenta()

    cursor.goto(column * columnWidth, (row * consoleLinesPerRow))
    cursor.eraseLine().write(definition.name)

    cursor.green()

    cursor.goto(column * columnWidth + metricsValueOffset, (row * consoleLinesPerRow) + 1)

    metric = representativeModel[definition.name]

    if metric == undefined || metric == null
      cursor.red()
      cursor.eraseLine().write('-')
    else if metric.isStale()
      cursor.red()
      cursor.eraseLine().write(metric.value + "")
    else
      cursor.green()
      cursor.eraseLine().write(metric.value + "")

    cursor.reset()



module.exports =
  notify: outputToConsole
  initialise: initialise
