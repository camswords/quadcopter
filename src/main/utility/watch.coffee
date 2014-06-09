define 'utility/watch', ['espruino/set-watch', 'espruino/clear-watch', 'utility/fail-whale', 'utility/is-number'], (setWatch, clearWatch, failWhale, isNumber) ->

  toDuration = (onChange) ->
    edgeUpTime = 0
    
    (event) ->
      if event.state == true
        edgeUpTime = event.time

      if event.state == false
        if edgeUpTime != 0
          duration = Math.floor((event.time - edgeUpTime) * 1000000)

          if isNumber(duration) && duration > 950 && duration < 2050
            onChange(duration)

        edgeUpTime = 0

  self = {}

  self.fallingEdge = (options) ->
    if options && options.pin && options.name && options.onChange
      setWatch(toDuration(options.onChange), options.pin, repeat: true, edge: 'falling')
    else
      failWhale("failed to start watch[#{options?.name}]. pin (#{options?.pin}), onChange and name must be specified.")

  self.clearAll = -> clearWatch()

  self
