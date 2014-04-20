
define 'propeller-test', ['spec-helper', 'mini-test-it'], (specHelper, it) ->

  it 'propeller should accelerate', (test) ->
    calledWithArguments = null
    digitalPulse = -> calledWithArguments = arguments.slice(0)
    stubs = 'espruino/digital-pulse': digitalPulse

    specHelper.require 'propeller', stubs, (propeller) ->
      propeller.create(78).accelerateTo(1500)

      test.expect(calledWithArguments).toBeTruthy()
      test.expect(calledWithArguments.length).toBe(3)
      test.expect(calledWithArguments[0]).toBe(78)
      test.expect(calledWithArguments[1]).toBe(1)
      test.expect(calledWithArguments[2]).toBe(1.5)
      test.done()



