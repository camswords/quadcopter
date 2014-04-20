define 'spec-helper', ->
  require: (moduleName, stubs, callback) ->
    if typeof(stubs) == 'function'
      callback = stubs
      stubs = {}

    define.newContext()

    for stubName, stubValue of stubs
      define.override(stubName, stubValue)

    require([moduleName], (callback))
