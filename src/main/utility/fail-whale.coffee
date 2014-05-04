
define 'utility/fail-whale', ->
  (message) -> new Error('FAIL WHALE: ', message)
