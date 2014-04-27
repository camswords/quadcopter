
define 'scheduler', ->
  self = {}

  self.after = (milliseconds) ->
    execute: (command) -> setTimeout(command, milliseconds)

  self.every = (milliseconds) ->
    execute: (command) ->
      scheduleJob = setInterval(command, milliseconds)
      stop: -> clearInterval(scheduleJob)

  self.continuously = -> self.every(1)

  self
