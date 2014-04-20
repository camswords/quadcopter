
define 'repository/throttle', ->
  throttle = 0

  save: (newThrottle) -> throttle = newThrottle
  get: -> throttle
