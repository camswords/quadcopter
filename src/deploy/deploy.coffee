espruino = require './espruino'

console.log('deploying')
code = 'setTimeout(function() { digitalWrite(LED2, false); }, 1000);'

success = -> console.log('\nsuccess!')
error = (error) -> console.log('\ndeploy failed!', error)
progress = -> process.stdout.write('.')

espruino.deploy(code).done(success, error, progress)
