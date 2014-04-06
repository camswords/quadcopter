require ['intensity'], (intensity) ->
  it "should be 0 when the time since the last pulse is NaN", (test) ->
    test.expect(intensity(NaN)).toBe(0)

  it "should be 100 when the time since last pulse is greater than 100", (test) ->
    test.expect(intensity(101)).toBe(100)

  it "should be 0 when the time since last pulse is less than 0", (test) ->
    test.expect(intensity(-100)).toBe(0)
