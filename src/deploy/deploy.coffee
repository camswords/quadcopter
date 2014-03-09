espruino = require './espruino'
printDots = require('./dot-printer')()
Q = require('q')

printWelcome = ->
  console.log('deploying')
  printDots.start()
  Q()

stopPrintingDots = ->
  printDots.stop()
  console.log()

reset = -> espruino.reset()
deploy = -> espruino.send('{ setTimeout(function() { digitalWrite(LED2, true); }, 10000); }\n')
success = -> console.log('success!')
error = (error) -> console.log('deploy failed!', error)

printWelcome().then(reset).then(deploy).finally(stopPrintingDots).done(success, error)
