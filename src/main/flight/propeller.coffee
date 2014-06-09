
define 'flight/propeller', [
    'utility/fail-whale', 'espruino/analog-write', 'configuration', 'repository/throttle-output'], (
    failWhale, analogWrite, config, throttleOutput) ->

  create: (pin) ->
    if !pin
      return failWhale("failed to create propeller, pin (#{pin}) was not specified.")

    accelerateTo: (throttle) ->
      dutyCycle = throttle / 10000 / 2
      throttleOutput.save(dutyCycle)

      analogWrite(pin, dutyCycle, freq: config.propeller.pwmFrequency)
