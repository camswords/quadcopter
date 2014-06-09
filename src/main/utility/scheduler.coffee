
define 'utility/scheduler', ->
  after: (milliseconds, command) -> setTimeout(command, milliseconds)
  every: (milliseconds, command) -> setInterval(command, milliseconds)
  stop: -> clearTimeout()
