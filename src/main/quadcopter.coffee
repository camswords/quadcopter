define 'quadcopter', [
         'watch', 'scheduler', 'repository/throttle', 'adjust-throttles', 'configuration'], (
         watch, scheduler, throttleRepository, adjustThrottles, config) ->

  fly: ->
    watch
      name: 'throttle'
      pin: config.throttle.inputPin
      onChange: (throttle) -> throttleRepository.save(throttle)

    scheduler.continuously().execute(adjustThrottles)


requirejs ['intensity'], (intensity) ->
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


  Receiver = (pin, quad) ->

    listenForEvents: =>
      updateThrottle = (event) ->
        sinceLastPulse = (event.time - event.lastTime) * 100000
        quad.throttle(intensity(sinceLastPulse))

      setWatch(updateThrottle, pin, repeat: true, edge: 'falling')

  quad = Quad()
  quad.startProps()

  receiver = Receiver(A13, quad)
  receiver.listenForEvents()
  console.log 'quadcopter started'
