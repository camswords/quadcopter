define 'utility/pwm', [
       'espruino/set-watch', 'espruino/clear-watch', 'utility/fail-whale', 'utility/is-number'], (
       setWatch, clearWatch, failWhale, isNumber) ->

  toDuration = (onChange) ->
    edgeUpTime = 0
    
    (event) ->
      if event.state == true
        edgeUpTime = event.time

      if event.state == false
        if edgeUpTime != 0
          duration = (event.time - edgeUpTime) * 50

          if isNumber(duration) && duration > 0.0475 && duration < 0.1025
            onChange(duration)

        edgeUpTime = 0

  self = {}

  self.watch = (options) ->
    if options && options.pin && options.onChange
      setWatch(toDuration(options.onChange), options.pin, repeat: true, edge: 'both')
    else
      failWhale("failed to watch pwm duty cycle on pin (#{options?.pin}). pin and onChange must be specified.")

  self.stopAllWatches = -> clearWatch()

  self
