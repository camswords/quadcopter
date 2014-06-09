
define 'flight/propeller', [
    'utility/fail-whale', 'espruino/analog-write', 'configuration'], (
    failWhale, analogWrite, config) ->

  create: (pin) ->
    if !pin
      return failWhale("failed to create propeller, pin (#{pin}) was not specified.")

    accelerateTo: (throttle) ->
      analogWrite(pin, throttle / 10000 / 2, freq: config.propeller.pwmFrequency)
