
define 'adjust-throttles-test', ['spec-helper', 'mini-test-it'], (specHelper, it) ->

  it 'adjust-throttles should adjust throttles of all propellers', (test) ->
    acceleratedTo = []

    propeller = create: ->
      accelerateTo: (throttle) -> acceleratedTo.push(throttle)

    stubs = 'propeller': propeller

    specHelper.require 'adjust-throttles' , stubs, (adjustThrottles) ->
      adjustThrottles(1234)

      test.expect(acceleratedTo.length).toBe(4)
      test.expect(acceleratedTo[0]).toBe(1234)
      test.expect(acceleratedTo[1]).toBe(1234)
      test.expect(acceleratedTo[2]).toBe(1234)
      test.expect(acceleratedTo[3]).toBe(1234)
      test.done()
