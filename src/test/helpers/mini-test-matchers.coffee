
define 'mini-test-matchers', ->
  all: (actual, errors) ->
    toBe: (expected) ->
      if actual != expected
        errors.push("Expected #{JSON.stringify(expected)}, to be #{JSON.stringify(actual)}")
