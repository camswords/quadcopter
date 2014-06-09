define 'utility/pwm-test', ['spec-helper', 'mini-test-it'], (specHelper, it) ->

  it "pwm should watch a pin", (test) ->
    calledWithArguments = null
    setWatch = -> calledWithArguments = arguments.slice(0)

    stubs = 'espruino/set-watch': setWatch

    specHelper.require 'utility/pwm', stubs, (pwm) ->
      pwm.watch
        pin: 56
        onChange: ->

      test.expect(calledWithArguments).toBeTruthy()
      test.done()

  it "pwm should call onChange with duration of edge rise", (test) ->
    setWatch = (callback) ->
      callback(time: 1.737293958663, state: true)
      callback(time: 1.738292932510, state: false)

    stubs = 'espruino/set-watch': setWatch

    specHelper.require 'utility/pwm', stubs, (pwm) ->
      pwm.watch
        pin: 1
        onChange: (value) ->
          test.expect(value).toBe(998)
          test.done()

  it "pwm should take the latest time when determining edge duration", (test) ->
    setWatch = (callback) ->
      callback(time: 5.4979, state: true)
      callback(time: 5.499, state: true)
      callback(time: 5.500, state: false)

    # why is this 999 not 1000? Seems like an Espruino rounding problem
    stubs = 'espruino/set-watch': setWatch

    specHelper.require 'utility/pwm', stubs, (pwm) ->
      pwm.watch
        pin: 1
        onChange: (value) ->
          test.expect(value).toBe(999)
          test.done()

  it "pwm should call onChange once when continuous pulse down events are found", (test) ->
    setWatch = (callback) ->
      callback(time: 5.499, state: true)
      callback(time: 5.500, state: false)
      callback(time: 5.550, state: false)

    stubs = 'espruino/set-watch': setWatch

    specHelper.require 'utility/pwm', stubs, (pwm) ->
      pwm.watch
        pin: 1
        onChange: (value) ->
          test.expect(value).toBe(999)
          test.done()

  it "pwm should call onChange when multiple up down transitions are detected", (test) ->
    setWatch = (callback) ->
      callback(time: 5.499, state: true)
      callback(time: 5.500, state: false)
      callback(time: 5.501, state: true)
      callback(time: 5.503, state: false)

    calledValues = []

    stubs = 'espruino/set-watch': setWatch

    specHelper.require 'utility/pwm', stubs, (pwm) ->
      pwm.watch
        pin: 1
        onChange: (value) ->
          calledValues.push(value)

          if calledValues.length == 2
            test.expect(calledValues[0]).toBe(999)
            test.expect(calledValues[1]).toBe(1999)
            test.done()

  it "pwm should ignore onChange when time for pulse up event is not a number", (test) ->
    setWatch = (callback) ->
      callback(time: NaN, state: true)
      callback(time: 1.738292932, state: false)
      callback(time: 1.739, state: true)
      callback(time: 1.740, state: false)

    stubs = 'espruino/set-watch': setWatch

    specHelper.require 'utility/pwm', stubs, (pwm) ->
      pwm.watch
        pin: 1
        onChange: (value) ->
          test.expect(value).toBe(1000)
          test.done()

  it "pwm should ignore onChange when time for pulse down event is not a number", (test) ->
    setWatch = (callback) ->
      callback(time: 1.736082933, state: true)
      callback(time: NaN, state: false)
      callback(time: 1.739, state: true)
      callback(time: 1.740, state: false)

    stubs = 'espruino/set-watch': setWatch

    specHelper.require 'utility/pwm', stubs, (pwm) ->
      pwm.watch
        pin: 1
        onChange: (value) ->
          test.expect(value).toBe(1000)
          test.done()

  it "pwm should ignore onChange when pulse duty cycle is more than two(ish) seconds", (test) ->
    setWatch = (callback) ->
      callback(time: 1.736082933, state: true)
      callback(time: 1.738292932, state: false)
      callback(time: 1.739, state: true)
      callback(time: 1.740, state: false)

    stubs = 'espruino/set-watch': setWatch

    specHelper.require 'utility/pwm', stubs, (pwm) ->
      pwm.watch
        pin: 1
        onChange: (value) ->
          test.expect(value).toBe(1000)
          test.done()

  it "pwm should ignore onChange when pulse duty cycle is less than one(ish) seconds", (test) ->
    setWatch = (callback) ->
      callback(time: 1.7371, state: true)
      callback(time: 1.738, state: false)
      callback(time: 1.739, state: true)
      callback(time: 1.740, state: false)

    stubs = 'espruino/set-watch': setWatch

    specHelper.require 'utility/pwm', stubs, (pwm) ->
      pwm.watch
        pin: 1
        onChange: (value) ->
          test.expect(value).toBe(1000)
          test.done()

  it "pwm should fail when options is not specified", (test) ->
    capturedMessage = null
    setWatch = ->
    failWhale = (message) -> capturedMessage = message

    stubs =
      'espruino/set-watch': setWatch,
      'utility/fail-whale': failWhale

    specHelper.require 'utility/pwm', stubs, (pwm) ->
      pwm.watch()
      test.expect(capturedMessage).toBe('failed to watch pwm duty cycle on pin (undefined). pin and onChange must be specified.')
      test.done()
#
  it "pwm should fail when pin is not specified", (test) ->
    capturedMessage = null
    setWatch = ->
    failWhale = (message) -> capturedMessage = message

    stubs =
      'espruino/set-watch': setWatch,
      'utility/fail-whale': failWhale

    specHelper.require 'utility/pwm', stubs, (pwm) ->
      pwm.watch onChange: ->
      test.expect(capturedMessage).toBe('failed to watch pwm duty cycle on pin (undefined). pin and onChange must be specified.')
      test.done()

  it "pwm should clear all watches", (test) ->
    called = false
    clearWatch = -> called = true

    stubs = 'espruino/clear-watch': clearWatch

    specHelper.require 'utility/pwm', stubs, (pwm) ->
      pwm.stopAllWatches()
      test.expect(called).toBeTruthy()
      test.done()
