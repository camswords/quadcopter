define 'quadcopter', [
         'utility/watch', 'utility/scheduler', 'repository/throttle', 'flight/adjust-throttles', 'configuration'], (
         watch, scheduler, throttleRepository, adjustThrottles, config) ->

  fly: ->
    watch.fallingEdge
      name: 'throttle'
      pin: config.throttle.inputPin
      onChange: (throttle) -> throttleRepository.save(throttle)

    scheduler.every(config.throttle.updateIntervalMs).execute 'adjust-throttles', ->
      adjustThrottles(throttleRepository.get())

  kill: ->
    scheduler.stopAll()
    watch.clearAll()
