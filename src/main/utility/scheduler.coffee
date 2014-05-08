
define 'utility/scheduler', ->
  self = {}
  self.jobs = {}

  self.after = (milliseconds) ->
    execute: (command) -> setTimeout(command, milliseconds)

  self.every = (milliseconds) ->
    execute: (name, command) ->
      self.jobs[name] = setInterval(command, milliseconds)

  self.continuously = -> self.every(1)

  self.stopAll = ->
    for job in Object.keys(self.jobs)
      self.stop(job)

  self.stop = (name) ->
    clearInterval(self.jobs[name])
    delete self.jobs[name]

  self
