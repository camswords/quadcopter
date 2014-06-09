define 'repository/analytics-test', ['spec-helper', 'mini-test-it'], (specHelper, it) ->

  it 'analytics repository should get throttle value', (test) ->
    stubs =
      'repository/throttle': get: -> 2000
      'repository/loop-frequency': get: -> 67

    specHelper.require 'repository/analytics', stubs, (analytics) ->
      test.expect(analytics.get()).toContainString('2000')
      test.done()

  it 'analytics repository should get loop count', (test) ->
    stubs =
      'repository/throttle': get: -> 1000
      'repository/loop-frequency': get: -> 45

    specHelper.require 'repository/analytics', stubs, (analytics) ->
      test.expect(analytics.get()).toContainString('45')
      test.done()
