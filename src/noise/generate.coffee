stats = require('./statistics')

minimumValue = 1
maximumValue = 2

random = -> Math.random() * (maximumValue - minimumValue + 1) + minimumValue

module.exports = ->
  for i in [1..10] by 1
    next = random()
    stats.push(next)
    console.log(next)
    
    
  console.log()
  console.log('avg', stats.mean())
  console.log('std', stats.standardDeviation())
  