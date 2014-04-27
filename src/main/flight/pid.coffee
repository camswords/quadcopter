
define 'flight/pid', ->
  create: (proportional, integral, differential, target) ->
    cumulativeError = 0
    lastError = 0

    (current) ->
      error = target - current
      diff = error - lastError
      lastError = error
      cumulativeError += error

      return (proportional * error) +
             (integral * cumulativeError) +
             (differential * diff)
