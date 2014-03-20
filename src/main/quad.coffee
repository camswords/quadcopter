Quad = ->
  throttle = 56

  startProps: ->
    setInterval (=>
      digitalPulse(C9, 1, 1 + E.clip(throttle / 100, 0, 1))
      digitalPulse(C8, 1, 1 + E.clip(throttle / 100, 0, 1))
      digitalPulse(C7, 1, 1 + E.clip(throttle / 100, 0, 1))
      digitalPulse(C6, 1, 1 + E.clip(throttle / 100, 0, 1))),
    50

  throttle: (newThrottle) -> throttle = newThrottle

Receiver = (pin, quad) ->

  listenForEvents: =>
    setWatch ((event) =>
      sinceLastPulse = (event.time - event.lastTime) * 100000
      intensity = Math.floor sinceLastPulse - 100;

      if isNaN(intensity)
        intensity = 0

      if intensity > 100
        intensity = 100

      if intensity < 0
        intensity = 0

      quad.throttle(intensity)),
      pin, {repeat: true, edge: 'falling'}

quad = Quad()
quad.startProps()

receiver = Receiver(A13, quad)
receiver.listenForEvents()


