defined = {}
waiting = {}

load = (name) ->
  waiting[name] = waiting[name] || Deferred.create()

  if defined[name] && !waiting[name].isFinished()
    if defined[name].dependencyNames.length == 0
      waiting[name].resolve defined[name].factory()
    else
      require defined[name].dependencyNames, ->
        waiting[name].resolve defined[name].factory.apply({}, arguments)

  waiting[name].promise


define = (name, dependencyNames, factory) ->
  return if defined[name]

  if !dependencyNames.slice
    factory = dependencyNames
    dependencyNames = []

  defined[name] = dependencyNames: dependencyNames, factory: factory

  if waiting[name]
    load(name).then (value) ->
      waiting[name].resolve(value)

require = (dependencyNames, factory) ->
  loaded = dependencyNames.map (name) -> load(name)

  Deferred.all(loaded).then (factoryArguments) ->
    factory.apply({}, factoryArguments)


define.all = -> Object.keys(defined)

define.newContext = ->
define.override = ->

