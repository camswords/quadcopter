cursor = require('ansi')(process.stdout)
_ = require('lodash')
protocol = require('./protocol')

columnWidth = 30
consoleLinesPerRow = 4
metricsValueOffset = 4


initialise = ->
  for row in [1..(protocol.suggestedNumberOfRows * consoleLinesPerRow) + 10] by 1
    cursor.goto(1, row).eraseLine()

outputValue = (cursor, column, row, value) ->
  whiteSpace = [1..(columnWidth - 1)].reduce ((accumulator)-> accumulator + ' '), ''
  cursor.goto(column, row)
        .write(whiteSpace)
        .goto(column, row)
        .write(value)

outputToConsole = (representativeModel) ->
  _.forEach protocol.definitions, (definition) ->

    cursor.magenta()
    headingColumn = (definition.column - 1) * columnWidth
    headingRow = (definition.row * consoleLinesPerRow)
    outputValue(cursor, headingColumn, headingRow, definition.name)

    valueColumn = (definition.column - 1) * columnWidth + metricsValueOffset
    valueRow = (definition.row * consoleLinesPerRow) + 1
    metric = representativeModel[definition.name]

    if metric == undefined || metric == null
      cursor.red()
      outputValue(cursor, valueColumn, valueRow, '-')
    else if metric.isStale()
      cursor.red()
      outputValue(cursor, valueColumn, valueRow, metric.value + '')
    else
      cursor.green()
      outputValue(cursor, valueColumn, valueRow, metric.value + '')

    cursor.reset()

module.exports =
  notify: outputToConsole
  initialise: initialise
