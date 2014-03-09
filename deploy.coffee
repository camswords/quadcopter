wait = require './wait'
espruino = require './espruino'
Q = require 'q'

finished = Q.defer()

success = (output) ->
  console.log('\nsuccess!')
  finished.resolve()

error = (error) ->
  console.log("deploy failed!", error)
  finished.reject(error)

deploy = -> espruino.send('{ digitalWrite(LED2, true); }\n')


console.log('deploying')
espruino.reset().then(deploy).done(success, error)

wait.until
  isSatisfied: -> !finished.promise.isPending()
  description: 'the espruino to reset'
