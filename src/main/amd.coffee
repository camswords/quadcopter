defined = {}
overrides = {}
waiting = {}
cached = {}
amdModuleMemory = {}

load = (name) ->
  loaded = Deferred.create()

  if name of defined
    if name of overrides
      loaded.resolve overrides[name]
    else if name of cached
      loaded.resolve cached[name]
    else
      require defined[name].dependencyNames, ->
        memoryBefore = process.memory().usage if define.config.recordMemory
        cached[name] = defined[name].factory.apply({}, arguments)
        amdModuleMemory[name] = (process.memory().usage - memoryBefore) if define.config.recordMemory

        if define.config.optimise
          delete defined[name].dependencyNames
          delete defined[name].factory

        loaded.resolve cached[name]
  else
    waiting[name] = waiting[name] && waiting || []
    waiting[name].push(loaded)

  loaded.promise

define = (name, dependencyNames, factory) ->
  return if defined[name]

  if !dependencyNames.slice
    factory = dependencyNames
    dependencyNames = []

  defined[name] = dependencyNames: dependencyNames, factory: factory

  if waiting[name]
    load(name).then (value) ->
      loaded.resolve(value) for loaded in waiting[name]
      delete waiting[name] if define.config.optimise

require = (dependencyNames, factory) ->
  loaded = dependencyNames.map (name) -> load(name)

  if dependencyNames.length == 0
    factory()
  else
    Deferred.all(loaded).then (factoryArguments) ->
      factory.apply({}, factoryArguments)

define.config =
  optimise: true
  recordMemory: false

define.all = -> Object.keys(defined)

# don't use new context / override with optimise: true,
# else new contexts wont be able to find module definitions.
define.newContext = ->
  overrides = {}
  waiting = {}
  cached = {}

define.override = (name, value) -> overrides[name] = value
