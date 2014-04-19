define 'mini-test', ['mini-test-it'], (it) ->
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

  run: ->
    specs = it.all()
    index = -1
    hasNext = -> index + 1 < specs.length
    next = -> specs[++index]

    runNextSpec = -> runSpec(next()) if hasNext()
    runSpec = (spec) -> spec.execute(newSpecContext(spec, runNextSpec))

    runNextSpec()
