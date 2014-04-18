define 'spec-helper', ->
  require: (moduleName, stubs, callback) ->
    define.newContext()

    for stubName, stubValue of stubs
      console.log "overridding #{stubName} to #{stubValue}"
      define.override(stubName, stubValue)

    requirejs([moduleName], (callback))
