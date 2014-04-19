define 'mini-test-it', ->
  specs = []

  it = (description, callback) ->
    specs.push(description: description, execute: callback)

  it.all = -> specs
  it
