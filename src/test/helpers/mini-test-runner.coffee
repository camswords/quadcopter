define 'mini-test-runner', ['mini-test-it', 'mini-test-matchers'], (it, matchers) ->
  newSpecContext = (spec, specComplete) ->
    errors = []

    expect: (actual) -> matchers.all(actual, errors)
    fail: (message) -> errors.push(message)
    done: ->
      if errors.length > 0
        console.log 'failed:', spec.description, JSON.stringify(errors)
      else
        console.log 'passed:', spec.description

      specComplete()

  run: ->
    specs = it.all()
    index = -1
    hasNext = -> index + 1 < specs.length
    next = -> specs[++index]

    runNextSpec = -> runSpec(next()) if hasNext()
    runSpec = (spec) -> spec.execute(newSpecContext(spec, runNextSpec))

    runNextSpec()
