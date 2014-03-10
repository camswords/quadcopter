espruino = require './espruino'
fs = require 'fs'

console.log('deploying')
code = fs.readFileSync('./src/main/quadcopter.js', encoding: 'utf-8')

success = -> console.log('\nsuccess!')
error = (error) -> console.log('\ndeploy failed!', error)
progress = -> process.stdout.write('.')

espruino.deploy(code).done(success, error, progress)
