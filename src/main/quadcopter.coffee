define 'quadcopter', [
         'utility/watch', 'utility/scheduler', 'repository/throttle', 'flight/adjust-throttles', 'configuration'], (
         watch, scheduler, throttleRepository, adjustThrottles, config) ->

  fly: ->
    watch
      name: 'throttle'
      pin: config.throttle.inputPin
      onChange: (throttle) -> throttleRepository.save(throttle)

    scheduler.continuously().execute 'adjustThrottles', adjustThrottles
