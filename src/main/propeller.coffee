
define 'propeller', ['espruino/digital-pulse', 'espruino/failWhale'], (digitalPulse, failWhale) ->
  create: (pin) ->
    if !pin
      return failWhale("failed to create propeller, pin (#{pin}) was not specified.")

    accelerateTo: (throttle) ->
      digitalPulse(pin, 1, throttle / 1000)
