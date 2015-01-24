
minimumValue = -10
maximumValue = 10

random = -> Math.random() * (maximumValue - minimumValue + 1) + minimumValue

module.exports = ->
  console.log random()
  