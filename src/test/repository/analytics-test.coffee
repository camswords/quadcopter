define 'repository/analytics-test', ['spec-helper', 'mini-test-it'], (specHelper, it) ->

  it 'analytics repository should sample time, loop count, throttle in and throttle out', (test) ->
    stubs =
      'espruino/time': -> 1
      'repository/loop-frequency': count: -> 2
      'repository/throttle': get: -> 3
      'repository/throttle-output': get: -> 4

    specHelper.require 'repository/analytics', stubs, (analytics) ->
      test.expect(analytics.headers()).toBe('time,loops,throttle in,throttle out')
      test.expect(analytics.get()).toContainString('1,2,3,4')
      test.done()
