define 'intensity-test', ['spec-helper', 'mini-test'], (specHelper, miniTest) ->
  miniTest.it "should be 0 when the time since the last pulse is NaN", (test) ->
    specHelper.require 'intensity', {}, (intensity) ->
      test.expect(intensity(NaN)).toBe(0)
      test.done()

  miniTest.it "should be 100 when the time since last pulse is greater than 100", (test) ->
    specHelper.require 'intensity', {}, (intensity) ->
      test.expect(intensity(101)).toBe(100)
      test.done()

  miniTest.it "should be 0 when the time since last pulse is less than 0", (test) ->
    specHelper.require 'intensity', {}, (intensity) ->
      test.expect(intensity(-100)).toBe(0)
      test.done()
