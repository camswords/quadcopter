define 'pid-test', ['spec-helper', 'mini-test-it'], (specHelper, it) ->

  it "pid should return the current error when past errors and delta are 0", (test) ->
    specHelper.require 'pid', (Pid) ->
      step = Pid.create(1, 0, 0, 1000)
      test.expect(step(900)).toBe(100)
      test.done()

  it "pid should return the sum of past errors when current and delta are 0", (test) ->
    specHelper.require 'pid', (Pid) ->
      step = Pid.create(0, 1, 0, 1000)
      test.expect(step(900)).toBe(100)
      test.expect(step(900)).toBe(200)
      test.done()

  it "pid should return the delta error when current and past errors are 0", (test) ->
    specHelper.require 'pid', (Pid) ->
      step = Pid.create(0, 0, 1, 1000)
      test.expect(step(900)).toBe(100)
      test.expect(step(900)).toBe(0)
      test.done()
