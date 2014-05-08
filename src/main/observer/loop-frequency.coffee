
define 'observer/loop-frequency', ['utility/scheduler', 'repository/metrics'], (scheduler, metricsRepository) ->
  loops = 0

  scheduler.every(1000).execute 'save-loop-frequency', ->
    metricsRepository.save('loop-frequency-hz', "#{loops}")
    loops = 0

  notify: -> loops++

