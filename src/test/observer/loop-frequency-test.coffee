
define 'observer/loop-frequency-test', ['spec-helper', 'mini-test-it'], (specHelper, it) ->

  it 'loop frequency observer should save loops per second', (test) ->
    timeoutCallback = ->
    metricName = null
    metricValue = null

    stubs = {
      'scheduler':
        every: -> execute: (callback) ->
          timeoutCallback = callback
      'repository/metrics': save: (name, value) ->
        metricName = name
        metricValue = value
    }

    specHelper.require 'observer/loop-frequency', stubs, (loopFrequencyObserver) ->
      loopFrequencyObserver.notify()
      loopFrequencyObserver.notify()
      loopFrequencyObserver.notify()
      loopFrequencyObserver.notify()
      timeoutCallback()

      test.expect(metricName).toBe('loop-frequency-hz')
      test.expect(metricValue).toBe('4')
      test.done()

  it 'loop frequency observer should reset loop count every second', (test) ->
    timeoutCallback = ->
    metricValues = []

    stubs = {
      'scheduler':
        every: -> execute: (callback) ->
          timeoutCallback = callback
      'repository/metrics': save: (name, value) -> metricValues.push(value)
    }

    specHelper.require 'observer/loop-frequency', stubs, (loopFrequencyObserver) ->
      loopFrequencyObserver.notify()
      timeoutCallback()
      timeoutCallback()

      test.expect(metricValues.length).toBe(2)
      test.expect(metricValues[0]).toBe('1')
      test.expect(metricValues[1]).toBe('0')
      test.done()
