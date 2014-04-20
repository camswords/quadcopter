define 'watch', ->
  (options) ->
    then: (callback) ->
      setWatch(callback, options.pin, repeat: true, edge: 'falling')
