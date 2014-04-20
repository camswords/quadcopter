
define 'scheduler', ->
  every: (milliseconds) ->
    execute: (command) -> setInterval(command, milliseconds)
