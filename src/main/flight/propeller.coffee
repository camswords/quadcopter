
define 'flight/propeller', [
    'utility/fail-whale', 'espruino/analog-write', 'configuration', 'repository/throttle-output'], (
    failWhale, analogWrite, config, throttleOutput) ->

  create: (pin) ->
    if !pin
      return failWhale("failed to create propeller, pin (#{pin}) was not specified.")

    accelerateTo: (throttle) ->
      analogWrite(pin, throttle, freq: config.propeller.pwmFrequency)
