define 'watch', ['setWatch', 'espruino/failWhale'], (setWatch, failWhale) ->
  (options) ->
    if options?.pin
      return then: (callback) ->
        setWatch(callback, options.pin, repeat: true, edge: 'falling')
    else
      failWhale('failed to start watch, pin is not specified')


