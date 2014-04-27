
define 'propeller-test', ['spec-helper', 'mini-test-it'], (specHelper, it) ->

  it 'propeller should accelerate', (test) ->
    calledWithArguments = null
    digitalPulse = -> calledWithArguments = arguments.slice(0)
    stubs = {
      'espruino/digital-pulse': digitalPulse
      'utility/is-number': (-> true)
    }

    specHelper.require 'propeller', stubs, (propeller) ->
      propeller.create(78).accelerateTo(1612)

      test.expect(calledWithArguments).toBeTruthy()
      test.expect(calledWithArguments.length).toBe(3)
      test.expect(calledWithArguments[0]).toBe(78)
      test.expect(calledWithArguments[1]).toBe(1)
      test.expect(calledWithArguments[2]).toBe(1.612)
      test.done()

  it 'propeller should accelerate by minimum amount when throttle is less than minimum', (test) ->
    capturedFrequency = null
    digitalPulse = (pin, value, frequency) -> capturedFrequency = frequency
    stubs = {
      'espruino/digital-pulse': digitalPulse
      'utility/is-number': (-> true)
    }

    specHelper.require 'propeller', stubs, (propeller) ->
      propeller.create(78).accelerateTo(900)

      test.expect(capturedFrequency).toBe(1)
      test.done()

  it 'propeller should accelerate by maximum amount when throttle is more than maximum', (test) ->
    capturedFrequency = null
    digitalPulse = (pin, value, frequency) -> capturedFrequency = frequency
    stubs = {
      'espruino/digital-pulse': digitalPulse
      'utility/is-number': (-> true)
    }

    specHelper.require 'propeller', stubs, (propeller) ->
      propeller.create(78).accelerateTo(2100)

      test.expect(capturedFrequency).toBe(2)
      test.done()

  it 'propeller should fail when pin is not specified', (test) ->
    capturedMessage = null
    stubs = 'utility/fail-whale': (message) -> capturedMessage = message

    specHelper.require 'propeller', stubs, (propeller) ->
      propeller.create(undefined)
      test.expect(capturedMessage).toBe('failed to create propeller, pin (undefined) was not specified.')
      test.done()

  it 'propeller should ignore request to accelerate when throttle is not a number', (test) ->
    called = false
    stubs = {
      'espruino/digital-pulse': (-> called = true)
      'utility/is-number': (-> false)
    }

    specHelper.require 'propeller', stubs, (propeller) ->
      propeller.create(1).accelerateTo("2100")

      test.expect(called).toBeFalsy()
      test.done()

