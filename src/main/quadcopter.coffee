define 'quadcopter', [
         'utility/watch', 'utility/scheduler', 'repository/throttle', 'flight/adjust-throttles', 'configuration'], (
         watch, scheduler, throttleRepository, adjustThrottles, config) ->

  fly: ->
    watch.fallingEdge
      name: 'throttle'
      pin: config.throttle.inputPin
      onChange: (throttle) -> throttleRepository.save(throttle)

    scheduler.continuously().execute 'adjust-throttles', adjustThrottles

  kill: ->
    scheduler.stopAll()
    watch.clearAll()
