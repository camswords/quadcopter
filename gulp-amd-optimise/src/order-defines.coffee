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
    ordered.push defines[moduleName] if moduleName != 'start'
    next()

  dag edges, 1, onEdge, (error) -> callback(error, ordered)
