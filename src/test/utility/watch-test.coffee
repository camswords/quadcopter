define 'utility/watch-test', ['spec-helper', 'mini-test-it'], (specHelper, it) ->

  it "watch should start watching a pin", (test) ->
    calledWithArguments = null
    setWatch = -> calledWithArguments = arguments.slice(0)

    specHelper.require 'utility/watch', { 'espruino/set-watch': setWatch }, (watch) ->
      watch.fallingEdge
        name: 'mywatch',
        pin: 56,
        onChange: ->

      test.expect(calledWithArguments).toBeTruthy()
      test.done()

  it "watch should call onChange with duration of edge rise", (test) ->
    setWatch = (callback) ->
      callback(time: 1.737293958663, state: true)
      callback(time: 1.738292932510, state: false)

    specHelper.require 'utility/watch', { 'espruino/set-watch': setWatch }, (watch) ->
      watch.fallingEdge
        name: 'mywatch',
        pin: 1,
        onChange: (value) ->
          test.expect(value).toBe(998)
          test.done()

  it "watch should take the latest time when determining edge duration", (test) ->
    setWatch = (callback) ->
      callback(time: 5.4979, state: true)
      callback(time: 5.499, state: true)
      callback(time: 5.500, state: false)

    # why is this 999 not 1000? Seems like an Espruino rounding problem
    specHelper.require 'utility/watch', { 'espruino/set-watch': setWatch }, (watch) ->
      watch.fallingEdge
        name: 'mywatch',
        pin: 1,
        onChange: (value) ->
          test.expect(value).toBe(999)
          test.done()

  it "watch should call onChange once when continuous pulse down events are found", (test) ->
    setWatch = (callback) ->
      callback(time: 5.499, state: true)
      callback(time: 5.500, state: false)
      callback(time: 5.550, state: false)

    specHelper.require 'utility/watch', { 'espruino/set-watch': setWatch }, (watch) ->
      watch.fallingEdge
        name: 'mywatch',
        pin: 1,
        onChange: (value) ->
          test.expect(value).toBe(999)
          test.done()

  it "watch should call onChange when multiple up down transitions are detected", (test) ->
    setWatch = (callback) ->
      callback(time: 5.499, state: true)
      callback(time: 5.500, state: false)
      callback(time: 5.501, state: true)
      callback(time: 5.503, state: false)

    calledValues = []

    specHelper.require 'utility/watch', { 'espruino/set-watch': setWatch }, (watch) ->
      watch.fallingEdge
        name: 'mywatch',
        pin: 1,
        onChange: (value) ->
          calledValues.push(value)

          if calledValues.length == 2
            test.expect(calledValues[0]).toBe(999)
            test.expect(calledValues[1]).toBe(1999)
            test.done()

  it "watch should ignore onChange when time for pulse up event is NaN", (test) ->
    setWatch = (callback) ->
      callback(time: NaN, state: true)
      callback(time: 1.738292932, state: false)
      callback(time: 1.739, state: true)
      callback(time: 1.740, state: false)

    specHelper.require 'utility/watch', { 'espruino/set-watch': setWatch }, (watch) ->
      watch.fallingEdge
        name: 'mywatch',
        pin: 1,
        onChange: (value) ->
          test.expect(value).toBe(1000)
          test.done()

  it "watch should ignore onChange when time for pulse down event is NaN", (test) ->
    setWatch = (callback) ->
      callback(time: 1.736082933, state: true)
      callback(time: NaN, state: false)
      callback(time: 1.739, state: true)
      callback(time: 1.740, state: false)

    specHelper.require 'utility/watch', { 'espruino/set-watch': setWatch }, (watch) ->
      watch.fallingEdge
        name: 'mywatch',
        pin: 1,
        onChange: (value) ->
          test.expect(value).toBe(1000)
          test.done()

  it "watch should ignore onChange when pulse duty cycle is more than two(ish) seconds", (test) ->
    setWatch = (callback) ->
      callback(time: 1.736082933, state: true)
      callback(time: 1.738292932, state: false)
      callback(time: 1.739, state: true)
      callback(time: 1.740, state: false)

    specHelper.require 'utility/watch', { 'espruino/set-watch': setWatch }, (watch) ->
      watch.fallingEdge
        name: 'mywatch',
        pin: 1,
        onChange: (value) ->
          test.expect(value).toBe(1000)
          test.done()

  it "watch should ignore onChange when pulse duty cycle is less than one(ish) seconds", (test) ->
    setWatch = (callback) ->
      callback(time: 1.7371, state: true)
      callback(time: 1.738, state: false)
      callback(time: 1.739, state: true)
      callback(time: 1.740, state: false)

    specHelper.require 'utility/watch', { 'espruino/set-watch': setWatch }, (watch) ->
      watch.fallingEdge
        name: 'mywatch',
        pin: 1,
        onChange: (value) ->
          test.expect(value).toBe(1000)
          test.done()

  it "watch should fail when options is not specified", (test) ->
    capturedMessage = null
    setWatch = ->
    failWhale = (message) -> capturedMessage = message

    stubs = { 'espruino/set-watch': setWatch, 'utility/fail-whale': failWhale }
    specHelper.require 'utility/watch', stubs, (watch) ->
      watch.fallingEdge()
      test.expect(capturedMessage).toBe('failed to start watch[undefined]. pin (undefined), onChange and name must be specified.')
      test.done()
#
  it "watch should fail when pin is not specified", (test) ->
    capturedMessage = null
    setWatch = ->
    failWhale = (message) -> capturedMessage = message

    stubs = { 'espruino/set-watch': setWatch, 'utility/fail-whale': failWhale }
    specHelper.require 'utility/watch', stubs, (watch) ->
      watch.fallingEdge name: 'mywatch', onChange: ->
      test.expect(capturedMessage).toBe('failed to start watch[mywatch]. pin (undefined), onChange and name must be specified.')
      test.done()

  it "watch should clear all watches", (test) ->
    called = false
    clearWatch = -> called = true

    stubs = { 'espruino/clear-watch': clearWatch }
    specHelper.require 'utility/watch', stubs, (watch) ->
      watch.clearAll()
      test.expect(called).toBeTruthy()
      test.done()
