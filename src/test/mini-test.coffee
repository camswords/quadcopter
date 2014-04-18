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
  it: (description, spec) ->
    test =
      errors: []

      expect: (actual) ->
        toBe: (expected) ->
          if actual != expected
            test.errors.push("Expected #{JSON.stringify(expected)}, to be #{JSON.stringify(actual)}")

      done: ->
        if test.errors.length > 0
          console.log 'failed:', description, JSON.stringify(test.errors)
        else
          console.log 'passed:', description

    spec(test)
