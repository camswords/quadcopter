
define 'mini-test-matchers', ->
  all: (actual, errors) ->
    toBe: (expected) ->
      if actual != expected
        errors.push("Expected #{JSON.stringify(actual)} to be #{JSON.stringify(expected)}")

    toBeLessThan: (expected) ->
      if !(actual < expected)
        errors.push("Expected #{JSON.stringify(actual)} to be less than #{JSON.stringify(expected)}")

    toBeGreaterThan: (expected) ->
      if !(actual > expected)
        errors.push("Expected #{JSON.stringify(actual)} to be greater than #{JSON.stringify(expected)}")

    toBeTruthy: ->
      if !actual
        errors.push("Expected #{JSON.stringify(actual)} to be truthy")

    toBeFalsy: ->
      if actual
        errors.push("Expected #{JSON.stringify(actual)} to be falsy")

