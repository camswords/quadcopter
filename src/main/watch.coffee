define 'watch', ['espruino/setWatch', 'espruino/fail-whale'], (setWatch, failWhale) ->

  toDuration = (onChange) ->
    (event) ->
      duration = Math.floor((event.time - event.lastTime) * 1000000)
      onChange(duration) unless isNaN(duration)

  (options) ->
    if options && options.pin && options.name && options.onChange
      setWatch(toDuration(options.onChange), options.pin, repeat: true, edge: 'falling')
    else
      failWhale("failed to start watch[#{options?.name}]. pin (#{options?.pin}), onChange and name must be specified.")
