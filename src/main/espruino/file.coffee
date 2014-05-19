
define 'espruino/file', ->
  (path) ->
    append: (data) -> fs.appendFile(path, data)
    read: -> fs.readFile(path)
