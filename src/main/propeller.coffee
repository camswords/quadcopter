
define 'propeller', ['espruino/digital-pulse'], (digitalPulse) ->
  create: (pin) ->
    accelerateTo: (throttle) ->
      digitalPulse(pin, 1, throttle / 1000)
