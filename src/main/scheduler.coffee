
define 'scheduler', ->
  self = {}

  self.every = (milliseconds) ->
    execute: (command) ->
      scheduleJob = setInterval(command, milliseconds)
      stop: -> clearInterval(scheduleJob)

  self.continuously = -> self.every(1)

  self
