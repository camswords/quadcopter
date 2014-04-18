it = (description, spec) ->
  test =
    errors: []

    expect: (actual) ->
      toBe: (expected) ->
        if actual != expected
          test.errors.push("Expected #{JSON.stringify(expected)}, to be #{JSON.stringify(actual)}")

  spec(test)

  if test.errors.length > 0
    console.log 'failed:', description, JSON.stringify(test.errors)
  else
    console.log 'passed:', description


define 'mini-test', ->
  specs = []

  newSpecContext = (spec, specComplete) ->
    errors = []

    return {
      expect: (actual) ->
        toBe: (expected) ->
          if actual != expected
            errors.push("Expected #{JSON.stringify(expected)}, to be #{JSON.stringify(actual)}")

      done: ->
        if errors.length > 0
          console.log 'failed:', spec.description, JSON.stringify(errors)
        else
          console.log 'passed:', spec.description

        specComplete()
    }


  it: (description, callback) ->
    specs.push(description: description, execute: callback)

  run: ->
    index = -1
    hasNext = -> index + 1 < specs.length
    next = -> specs[++index]

    runNextSpec = -> runSpec(next()) if hasNext()
    runSpec = (spec) -> spec.execute(newSpecContext(spec, runNextSpec))

    runNextSpec()
