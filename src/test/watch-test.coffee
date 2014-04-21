define 'watch-test', ['spec-helper', 'mini-test-it'], (specHelper, it) ->

  it "watch should start watching a pin", (test) ->
    calledWithArguments = null
    setWatch = -> calledWithArguments = arguments.slice(0)

    specHelper.require 'watch', { 'espruino/setWatch': setWatch }, (watch) ->
      watch
        name: 'mywatch',
        pin: 56,
        onChange: ->

      test.expect(calledWithArguments).toBeTruthy()
      test.done()

  it "watch should call onChange with duration of edge rise", (test) ->
    setWatch = (callback) -> callback(time: 1397984610.738292932510, lastTime: 1397984610.737293958663)

    specHelper.require 'watch', { 'espruino/setWatch': setWatch }, (watch) ->
      watch
        name: 'mywatch',
        pin: 1,
        onChange: (value) ->
          test.expect(value).toBe(998)
          test.done()

  it "watch should not call onChange when cannot determine duration of edge rise", (test) ->
    setWatch = (callback) -> callback(time: 1397984610.738292932510, lastTime: NaN)

    specHelper.require 'watch', { 'espruino/setWatch': setWatch }, (watch) ->
      watch
        name: 'mywatch',
        pin: 1,
        onChange: -> test.fail('expect on change not to be called')

      test.done()

  it "watch should fail when options is not specified", (test) ->
    capturedMessage = null
    setWatch = ->
    failWhale = (message) -> capturedMessage = message

    stubs = { 'espruino/setWatch': setWatch, 'espruino/fail-whale': failWhale }
    specHelper.require 'watch', stubs, (watch) ->
      watch()
      test.expect(capturedMessage).toBe('failed to start watch[undefined]. pin (undefined), onChange and name must be specified.')
      test.done()

  it "watch should fail when pin is not specified", (test) ->
    capturedMessage = null
    setWatch = ->
    failWhale = (message) -> capturedMessage = message

    stubs = { 'espruino/setWatch': setWatch, 'espruino/fail-whale': failWhale }
    specHelper.require 'watch', stubs, (watch) ->
      watch name: 'mywatch', onChange: ->
      test.expect(capturedMessage).toBe('failed to start watch[mywatch]. pin (undefined), onChange and name must be specified.')
      test.done()
