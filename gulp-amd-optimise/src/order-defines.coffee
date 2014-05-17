dag = require 'breeze-dag'

module.exports = (defines, callback) ->
  return callback(null, []) if !defines

  edges = []
  ordered = []

  Object.keys(defines).forEach (moduleName) ->
    dependencyNames = defines[moduleName].dependencyNames

    dependencyNames.forEach (dependencyName) ->
      edges.push([dependencyName, moduleName])

    edges.push(['start', moduleName])


  onEdge = (moduleName, next) ->
    if moduleName != 'start'
      module = defines[moduleName]
      module.name = moduleName

      ordered.push(module)

    next()


  onDone = (error) -> callback(error, ordered)

  dag(edges, 1, onEdge, onDone)
