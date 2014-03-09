wait = require './wait'
espruino = require './espruino'

success = (output) -> console.log('\n', output)
error = (error) -> console.log("deploy failed!", error)

reset = espruino.reset()
reset.then(success, error)

wait.until
  isSatisfied: -> !reset.isPending()
  description: 'the espruino to reset'
