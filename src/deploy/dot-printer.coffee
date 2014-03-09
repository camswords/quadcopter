
module.exports = ->
  interval = null

  self =
    start: ->
      self.stop()
      interval = setInterval((-> process.stdout.write('.')), 100)

    stop: -> clearInterval(interval) if interval

  self
