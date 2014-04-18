define 'spec-helper', ->
  require: (moduleName, stubs, callback) ->
    define.newContext()

    for stubName, stubValue of stubs
      define.override(stubName, stubValue)

    require([moduleName], (callback))
