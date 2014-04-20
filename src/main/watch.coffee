define 'watch', ['espruino/setWatch', 'espruino/failWhale'], (setWatch, failWhale) ->
  (options) ->
    if options && options.pin && options.name && options.onChange
      setWatch(options.onChange, options.pin, repeat: true, edge: 'falling')
    else
      failWhale("failed to start watch[#{options?.name}]. pin (#{options?.pin}), onChange and name must be specified.")


