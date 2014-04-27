
define 'flight/adjust-throttles-test', ['spec-helper', 'mini-test-it'], (specHelper, it) ->

  it 'adjust-throttles should adjust throttles of all propellers', (test) ->
    acceleratedTo = []

    propeller = create: ->
      accelerateTo: (throttle) -> acceleratedTo.push(throttle)

    stubs = {
      'flight/propeller': propeller
      'observer/loop-frequency': notify: (->)
    }

    specHelper.require 'flight/adjust-throttles' , stubs, (adjustThrottles) ->
      adjustThrottles(1234)

      test.expect(acceleratedTo.length).toBe(4)
      test.expect(acceleratedTo[0]).toBe(1234)
      test.expect(acceleratedTo[1]).toBe(1234)
      test.expect(acceleratedTo[2]).toBe(1234)
      test.expect(acceleratedTo[3]).toBe(1234)
      test.done()

  it 'adjust-throttles should notify loop frequency observer when it has adjusted throttles', (test) ->
    timesNotified = 0

    stubs = {
      'flight/propeller': create: -> accelerateTo: (->)
      'observer/loop-frequency': notify: -> timesNotified++
    }

    specHelper.require 'flight/adjust-throttles' , stubs, (adjustThrottles) ->
      adjustThrottles(1234)
      adjustThrottles(1250)
      adjustThrottles(1212)

      test.expect(timesNotified).toBe(3)
      test.done()
