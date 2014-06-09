define 'repository/throttle-output', ->
  throttle = 0

  save: (newThrottle) -> throttle = newThrottle
  get: -> throttle
