
define('quad', {})

digitalWrite(LED1, false);
digitalWrite(LED2, false);
digitalWrite(LED3, false);

Quad = ->
  throttle = 56

  startProps: ->
#    setInterval (=>
      digitalPulse(C9, 1, 1 + E.clip(throttle / 100, 0, 1))
      digitalPulse(C8, 1, 1 + E.clip(throttle / 100, 0, 1))
      digitalPulse(C7, 1, 1 + E.clip(throttle / 100, 0, 1))
      digitalPulse(C6, 1, 1 + E.clip(throttle / 100, 0, 1))
#      50

  throttle: (newThrottle) -> throttle = newThrottle


newIntensity = (sinceLastPulse) ->
  intensity = sinceLastPulse

  if isNaN(intensity)
    intensity = 0

  if intensity > 100
    intensity = 100

  if intensity < 0
    intensity = 0

  intensity

Receiver = (pin, quad) ->

  listenForEvents: =>
    updateThrottle = (event) ->
      sinceLastPulse = (event.time - event.lastTime) * 100000
      quad.throttle(newIntensity(sinceLastPulse))

    setWatch(updateThrottle, pin, repeat: true, edge: 'falling')

quad = Quad()
quad.startProps()

receiver = Receiver(A13, quad)
receiver.listenForEvents()

require ['quad'], -> console.log 'quadcopter started'
