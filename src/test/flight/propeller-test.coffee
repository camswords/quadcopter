
define 'flight/propeller-test', ['spec-helper', 'mini-test-it'], (specHelper, it) ->

  it 'propeller should accelerate to desired speed', (test) ->
    calledWithArguments = []

    stubs = 'espruino/analog-write': ->
      calledWithArguments = arguments.slice(0)

    specHelper.require 'flight/propeller', stubs, (propeller) ->
      propeller.create(78).accelerateTo(0.05)

      test.expect(calledWithArguments).toBeTruthy()
      test.expect(calledWithArguments.length).toBe(3)
      test.expect(calledWithArguments[1]).toBe(0.05)
      test.done()

  it 'propeller should update using configured frequency', (test) ->
    calledWithArguments = []

    stubs =
      'espruino/analog-write': -> calledWithArguments = arguments.slice(0)
      'configuration': propeller: pwmFrequency: 55

    specHelper.require 'flight/propeller', stubs, (propeller) ->
      propeller.create(1).accelerateTo(0.1)

      test.expect(calledWithArguments).toBeTruthy()
      test.expect(calledWithArguments.length).toBe(3)
      test.expect(calledWithArguments[2]?.freq).toBe(55)
      test.done()

  it 'propeller should fail when pin is not specified', (test) ->
    capturedMessage = null
    stubs = 'utility/fail-whale': (message) -> capturedMessage = message

    specHelper.require 'flight/propeller', stubs, (propeller) ->
      propeller.create(undefined)
      test.expect(capturedMessage).toBe('failed to create propeller, pin (undefined) was not specified.')
      test.done()
