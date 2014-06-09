
define 'utility/scheduler', ->

  after: (milliseconds) ->
    execute: (command) -> setTimeout(command, milliseconds)

  every: (milliseconds) ->
    execute: (name, command) -> setInterval(command, milliseconds)

  stopAll: -> clearTimeout()
