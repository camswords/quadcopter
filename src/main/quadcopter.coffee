define 'quadcopter', [
         'utility/pwm', 'utility/scheduler', 'repository/throttle', 'flight/adjust-throttles', 'configuration', 'utility/analytics-gateway', 'repository/analytics'], (
         pwm, scheduler, throttleRepository, adjustThrottles, config, analyticsGateway, analyticsRepository) ->

  fly: ->
    pwm.watch
      pin: config.throttle.inputPin
      onChange: (throttle) -> throttleRepository.save(throttle)

    scheduler.every config.throttle.updateIntervalMs, ->
      adjustThrottles(throttleRepository.get())

    scheduler.every config.analytics.sampleTimeMs, ->
      analyticsGateway.send(analyticsRepository.get())

  kill: ->
    scheduler.stop()
    pwm.stopAllWatches()
