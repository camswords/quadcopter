
define 'propeller', ['espruino/digital-pulse', 'espruino/fail-whale'], (digitalPulse, failWhale) ->
  create: (pin) ->
    if !pin
      return failWhale("failed to create propeller, pin (#{pin}) was not specified.")

    accelerateTo: (throttle) ->
      safeThrottle = Math.max(1000, Math.min(throttle, 2000))

      digitalPulse(pin, 1, safeThrottle / 1000)
