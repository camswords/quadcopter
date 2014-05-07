
define 'utility/scheduler', ->
  self = {}
  self.jobs = {}

  self.after = (milliseconds) ->
    execute: (name, command) -> setTimeout(command, milliseconds)

  self.every = (milliseconds) ->
    execute: (name, command) ->
      self.jobs[name] = setInterval(command, milliseconds)

  self.continuously = -> self.every(1)

  self.stop = (name) ->
    clearInterval(self.jobs[name])
    delete self.jobs[name]

  self
