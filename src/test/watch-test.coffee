define 'watch-test', ['spec-helper', 'mini-test-it'], (specHelper, it) ->

  it "watch should start watching a pin", (test) ->
    calledWithArguments = null
    setWatch = -> calledWithArguments = arguments.slice(0)

    specHelper.require 'watch', { 'setWatch': setWatch }, (watch) ->
      watch(pin: 56).then(->)
      test.expect(calledWithArguments).toBeTruthy()
      test.done()

  it "watch should fail when options is not specified", (test) ->
    capturedMessage = null
    setWatch = ->
    failWhale = (message) -> capturedMessage = message

    specHelper.require 'watch', { 'setWatch': setWatch, 'failWhale': failWhale }, (watch) ->
      watch()
      test.expect(capturedMessage).toBe('failed to start watch, pin is not specified')
      test.done()

  it "watch should fail when pin is not specified", (test) ->
    capturedMessage = null
    setWatch = ->
    failWhale = (message) -> capturedMessage = message

    specHelper.require 'watch', { 'setWatch': setWatch, 'failWhale': failWhale }, (watch) ->
      watch({})
      test.expect(capturedMessage).toBe('failed to start watch, pin is not specified')
      test.done()
