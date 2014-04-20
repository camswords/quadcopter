
define 'throttleRepository', ->
  throttle = 0

  save: (newThrottle) -> throttle = newThrottle
  get: -> throttle
