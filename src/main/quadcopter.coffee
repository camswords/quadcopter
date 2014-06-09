define 'quadcopter', [
         'utility/pwm', 'utility/scheduler', 'repository/throttle', 'flight/adjust-throttles', 'configuration'], (
         pwm, scheduler, throttleRepository, adjustThrottles, config) ->

  fly: ->
    pwm.watch
      pin: config.throttle.inputPin
      onChange: (throttle) -> throttleRepository.save(throttle)

    scheduler.every(config.throttle.updateIntervalMs).execute 'adjust-throttles', ->
      adjustThrottles(throttleRepository.get())

  kill: ->
    scheduler.stopAll()
    pwm.stopAllWatches()
