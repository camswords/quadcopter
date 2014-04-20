
define 'scheduler', ->
  every: (milliseconds) ->
    execute: (command) ->
      scheduleJob = setInterval(command, milliseconds)
      stop: -> clearInterval(scheduleJob)
