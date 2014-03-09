espruino = require './espruino'
printDots = require('./dot-printer')()

success = ->
  printDots.stop()
  console.log('\nsuccess!')

error = (error) ->
  printDots.stop()
  console.log("deploy failed!", error)

console.log('deploying')
printDots.start()


deploy = -> espruino.send('{ digitalWrite(LED2, true); }\n')



espruino.reset().then(deploy).done(success, error)
