
define 'espruino/fail-whale', ->
  (message) ->
    console.log('FAIL WHALE: ', message)
    quit()
